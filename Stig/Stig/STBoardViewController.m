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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) requestDataForIndexPath:(NSIndexPath *)indexPath {
    STBoardComment *comment = self.comments[indexPath];
    if (comment) {
        [_overlord resolveUserById:comment.userId completion:^(STUser *user) {
            [_commentsUsers setObject:user forKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        }error:^(NSError *error){
            
        }];
    }
}
- (void) requestData{
    NSLog(@"request data %@", self.place);
        self.title = self.place.placeName;
        [_overlord getCommentsFromPlace:self.place withStickers:@[@3,@1,@2] pageNumber:0 completion:^(NSArray *comments, NSUInteger pageNumber){
            _comments = [[NSMutableDictionary alloc] initWithCapacity:[comments count]];
            _commentsUsers = [[NSMutableDictionary alloc] initWithCapacity:[comments count]];
            for (int i =0; i < [comments count]; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1 inSection:0];
                
                STBoardComment *comment = comments[i];
                [_comments setObject:comment forKey:indexPath];
                [self setHeightForComment:comment AtIndexPath:indexPath];
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
    
    STBoardComment *comment = self.comments[indexPath];
    STUser *user = self.commentsUsers[indexPath];
    
    if (user&&comment) {
        STBoardCommentView *commentView =(STBoardCommentView *) [cell.contentView viewWithTag:100];
        commentView.commentFont = self.commentFont;
        commentView.userNameFont = self.userNameFont;
        [commentView populateCommentWithText:comment.commentText userName:user.userName userImageURL:user.userImageURL andTimestamp:comment.commentTimestamp];
    } else {
        [self requestDataForIndexPath:indexPath];
    }
    return cell;
}
- (void) setHeightForComment:(STBoardComment *) comment AtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *text = [NSString stringWithFormat:@"Rafael Nunes\n%@\n9999 days ago",comment.commentText];
    
    CGSize stringSize = [text sizeWithFont:self.commentFont constrainedToSize:CGSizeMake(230.0, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    stringSize.height = MAX(stringSize.height, 40.0);
    [_heightsDictionary setObject:@(stringSize.height+20.0) forKey:indexPath];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [_heightsDictionary objectForKey:indexPath];
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
