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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Futura" size:20.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.place.placeName;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.customNavigationItem.titleView = label;
    self.userNameFont = [UIFont fontWithName:@"Futura" size:16.0];
    self.commentFont =  [UIFont fontWithName:@"Helvetica" size:14.0];
    _overlord = [STHiveCluster spawnOverlord];
    [self.topBatTitle setText:self.place.placeName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
    [button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"Button Back NOVO.png"] forState:UIControlStateNormal];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

    UIButton *buttonPost = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonPost setFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
    [buttonPost addTarget:self action:@selector(postButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPost setImage:[UIImage imageNamed:@"icon_post.png"] forState:UIControlStateNormal];

    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonPost];
    [self.customNavigationItem setRightBarButtonItem:leftButtonItem];
    [self.customNavigationItem setLeftBarButtonItem:barButtonItem];
    
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
- (IBAction)stickerButtonPressed:(UIButton *)sender {
    self.stickersView.hidden = !self.stickersView.hidden;
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)postButtonPressed:(id)sender {
    STComposePostViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"STComposePostViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) stickerPickerSelectionDidChange:(STStickerPickerView *)stickerPicker {
    [self requestDataWithStickers:stickerPicker.selectedStickers];
}
@end
