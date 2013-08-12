//
//  STBoardViewController.m
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STBoardViewController.h"


@interface STBoardViewController ()
 
@end

@implementation STBoardViewController{
    NSMutableDictionary *_heightsDictionary;
    STOverlord *_overlord;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Futura" size:20.0];
    //label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.place.placeName;
    label.textColor = [UIColor whiteColor]; // change this color
    [label sizeToFit];
    self.customNavigationItem.titleView = label;
    self.tableView.contentInset = UIEdgeInsetsMake(-144.0, 0.0, 0.0, 0.0);
    self.userNameFont = [UIFont fontWithName:@"Futura" size:16.0];
    self.commentFont =  [UIFont fontWithName:@"Helvetica" size:14.0];
    _heightsDictionary = [[NSMutableDictionary alloc] initWithCapacity:30];
    _loadedPlace = NO;
    _loadedComments = NO;
    _overlord = [STOverlord sharedInstance];
    [self.topBatTitle setText:self.place.placeName];
    [self requestData];


    // register for keyboard notifications
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:self.view.window];
//    // register for keyboard notifications
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:self.view.window];




    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
    [button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"Button Back NOVO.png"] forState:UIControlStateNormal];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

    [self.customNavigationItem setLeftBarButtonItem:barButtonItem];

    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) requestDataForIndexPath:(NSIndexPath *)indexPath {
    STBoardComment *comment = self.comments[@(indexPath.row)];
    if (comment) {
        [_overlord resolveUserById:comment.userId completion:^(STUser *user) {
            [_commentsUsers setObject:user forKey:@(indexPath.row)];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }error:^(NSError *error){
            NSLog(@"Error ...");
        }];
    }
}
- (void) requestData{
    self.title = self.place.placeName;
    [_overlord getCommentsFromPlace:self.place withStickers:@[@3,@1,@2] pageNumber:0 completion:^(NSArray *comments, NSUInteger pageNumber){
        _comments = [[NSMutableDictionary alloc] initWithCapacity:[comments count]];
        _commentsUsers = [[NSMutableDictionary alloc] initWithCapacity:[comments count]];
        for (int i =0; i < [comments count]; i++) {
            STBoardComment *comment = comments[i];
            [_comments setObject:comment forKey:@(i+1)];
            [self setHeightForComment:comment atPosition:@(i+1)];
        }
        [self.tableView reloadData];
        _loadedComments = YES;
    }error:^(NSError *error){
        NSLog(@"erro 2 %@",error);
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.comments) {
        return [self.comments count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row]==0) {
        static NSString *CellIdentifier = @"STBoardHeaderIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 244.0f)];
        
        [imageView setImageWithURL:[NSURL URLWithString:self.place.imageURL] placeholderImage:[UIImage imageNamed:@"uk-board.jpg"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:YES];
        [cell.contentView addSubview:imageView];
        [cell.contentView sendSubviewToBack:imageView];
        return cell;
    }
    static NSString *CellIdentifier = @"STBoardCommentIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    STBoardComment *comment = self.comments[@(indexPath.row)];
    STUser *user = self.commentsUsers[@(indexPath.row)];
    
    if (user&&comment) {
        STBoardCommentView *commentView = (STBoardCommentView *) [cell.contentView viewWithTag:100];
        commentView.commentFont = self.commentFont;
        commentView.userNameFont = self.userNameFont;
        [commentView populateCommentWithText:comment.commentText userName:user.userName userImageURL:user.userImageURL andTimestamp:comment.commentTimestamp];
    } else {
        [self requestDataForIndexPath:indexPath];
    }
    return cell;
}
- (void) setHeightForComment:(STBoardComment *) comment atPosition:(NSNumber *) position {
    NSString *text = [NSString stringWithFormat:@"Rafael Nunes\n%@\n9999 days ago",comment.commentText];

    CGSize stringSize = [text sizeWithFont:self.commentFont constrainedToSize:CGSizeMake(230.0, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    stringSize.height = MAX(stringSize.height, 40.0);
    [_heightsDictionary setObject:@(stringSize.height+20.0) forKey:position];
}

#pragma mark - Table view delegate
- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [_heightsDictionary objectForKey:@(indexPath.row)];
    if (height) {
        return [height floatValue];
    }
    return 244.0;
}
- (IBAction)stickerButtonPressed:(UIButton *)sender {
    self.stickersView.hidden = !self.stickersView.hidden;
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField  {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    //self.view.transform = CGAffineTransformMakeTranslation(0.0, -300.0);
    return YES;
}
- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    //self.view.transform = CGAffineTransformIdentity;
    return YES;
}


- (void)keyboardWillHide:(NSNotification *)n
{

    NSDictionary* userInfo = [n userInfo];
    NSNumber *number = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    double duration = [number doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self.view setTransform:CGAffineTransformIdentity];
    }];
}

- (void)keyboardWillShow:(NSNotification *)n
{
    

    NSDictionary* userInfo = [n userInfo];

    NSNumber *number = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    double duration = [number doubleValue];
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:duration animations:^{
        [self.view setTransform:CGAffineTransformMakeTranslation(0.0, -keyboardSize.height)];
    }];
    // resize the noteView
    
}
@end
