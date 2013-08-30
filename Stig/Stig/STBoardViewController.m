//
//  STBoardViewController.m
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STBoardViewController.h"
#import "STComposePostViewController.h"

@interface STBoardViewController ()
 
@end

@implementation STBoardViewController{
    NSMutableDictionary *_heightsDictionary;
    id<STOverlord> _overlord;
    NSUInteger _currentToken;
    NSUInteger _numberOfCommentsForToken;
    BOOL _loadedMetadata;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userNameFont = [UIFont fontWithName:@"Futura" size:16.0];
    self.commentFont =  [UIFont fontWithName:@"Helvetica" size:14.0];
    _overlord = [STHiveCluster spawnOverlord];
    [self.topBatTitle setText:self.place.placeName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
    [button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

    UIButton *buttonPost = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonPost setFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
    [buttonPost addTarget:self action:@selector(postButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPost setImage:[UIImage imageNamed:@"icon_post.png"] forState:UIControlStateNormal];

    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonPost];
    [self.navigationItem setRightBarButtonItem:leftButtonItem];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    self.title = self.place.placeName;
    _loadedMetadata = NO;
    [self requestDataWithStickers:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) requestDataWithStickers:(NSArray *) stickers {
    NSLog(@"REquesting data!");
    NSUInteger token = [_overlord requestTokenForBoard:self.place filteringWithStickers:stickers];
    _currentToken = token;
    [_overlord getNumberOfCommentsForToken:token completion:^(NSUInteger numberOfCommentsForToken){
        _numberOfCommentsForToken = numberOfCommentsForToken;
        _loadedMetadata = YES;
        _heightsDictionary = [[NSMutableDictionary alloc] initWithCapacity:30];
        [self.tableView reloadData];
    }error:^(NSError *error) {
        NSLog(@"REquesting data! AND BIG ERROR %@ %@", error, self.place);
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        if (_loadedMetadata) {
            return _numberOfCommentsForToken;
        }
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section]==0) {
        static NSString *CellIdentifier = @"STBoardHeaderIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 100.0f)];
        
        [imageView setImageWithURL:[NSURL URLWithString:self.place.imageURL] placeholderImage:[UIImage imageNamed:@"uk-board.jpg"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:YES];
        [cell.contentView addSubview:imageView];
        [cell.contentView sendSubviewToBack:imageView];
        return cell;
    }
    static NSString *CellIdentifier = @"STBoardCommentIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    STBoardCommentView *reuse = (STBoardCommentView *) [cell.contentView viewWithTag:100];
    [reuse prepareForReuse];
    [_overlord getCommentAndUserForToken:_currentToken andPosition:indexPath.row completion:^(STBoardComment *comment, STUser *user){
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        STBoardCommentView *commentView = (STBoardCommentView *) [currentCell.contentView viewWithTag:100];
        commentView.commentFont = self.commentFont;
        commentView.userNameFont = self.userNameFont;
        [commentView populateWithComment:comment andUser:user];
        NSNumber *position = @(indexPath.row);
        if (!_heightsDictionary[position]) {
            [self setHeight:commentView.cellHeight forPosition:position];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }error:^(NSError *error){

    }];
    return cell;
}
- (void) setHeight:(CGFloat) height forPosition:(NSNumber *) position {
    [_heightsDictionary setObject:@(height) forKey:position];
}
#pragma mark - Table view delegate
- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 100.0;
    }
    NSNumber *height = [_heightsDictionary objectForKey:@(indexPath.row)];
    if (height) {
        return [height floatValue];
    }
    return 80.0;
}

- (void) stickerPickerSelectionDidChange:(STStickerPickerView *)stickerPicker {
    self.selectedStickers = stickerPicker.selectedStickers;
    [self requestDataWithStickers:self.selectedStickers];
}
- (void) backButtonPressed:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)postButtonPressed:(id)sender {
    if (_overlord.user) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        STComposePostViewController * vc = [sb instantiateViewControllerWithIdentifier:@"STComposePostViewController"];
        vc.completionHandler = ^(BOOL completed) {
            if (completed) {
                [self requestDataWithStickers:self.selectedStickers];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error on comment post"delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
            }

        };
        vc.overlordToken = _currentToken;
        vc.place = self.place;
        [self presentViewController:vc animated:YES completion:nil];
    }else {
        [self performSegueWithIdentifier:@"logInSegue" sender:sender];
    }
}
@end
