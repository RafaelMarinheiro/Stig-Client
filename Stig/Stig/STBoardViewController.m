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
    BOOL _viewAppearing;
}
- (void) viewWillAppear:(BOOL)animated {
    _viewAppearing = YES;
}
- (void) viewWillDisappear:(BOOL)animated {
    _viewAppearing = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _overlord = [STHiveCluster spawnOverlord];
    
    [self setupViews];
    self.title = self.place.placeName;
    _loadedMetadata = NO;
    
    [self refreshData:^(BOOL completed) {
        if (completed) {
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
            [self.refreshControl endRefreshing];
        }else {
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Failed to load data"];
        }
    }];
}
- (void) setupViews {
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


    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading"];
    [refresh addTarget:self
                action:@selector(refreshView:)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.refreshControl beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overlord Communication

- (void) refreshData:(void(^)(BOOL completed))completion {
    NSUInteger token = [_overlord requestTokenForBoard:self.place filteringWithStickers:self.selectedStickers];
    _currentToken = token;
    [_overlord getNumberOfCommentsForToken:token completion:^(NSUInteger numberOfCommentsForToken){
        if (_viewAppearing) {
            _numberOfCommentsForToken = numberOfCommentsForToken;
            _loadedMetadata = YES;
            _heightsDictionary = [[NSMutableDictionary alloc] initWithCapacity:30];
            [self.tableView reloadData];
            if (completion) {
                completion(YES);
            }
        }
    }error:^(NSError *error) {
        NSLog(@"REquesting data! AND BIG ERROR %@ %@", error, self.place);
        if (completion) {
            completion(NO);
        }
    }];
}
- (UITableViewCell *) getHeaderCellFromTableView:(UITableView *) tableView{
    static NSString *CellIdentifier = @"STBoardHeaderIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 100.0f)];
    STStickerPickerView *picker = (STStickerPickerView *)[cell.contentView viewWithTag:12];
    [picker setStickers:self.place.stickers];
 
    [imageView setImageWithURL:[NSURL URLWithString:self.place.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder_place"]];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    [cell.contentView addSubview:imageView];
    [cell.contentView sendSubviewToBack:imageView];
    return cell;
}
- (UITableViewCell *) getCommentCellFromTableView:(UITableView *) tableView andIndexPath:(NSIndexPath *) indexPath{
    static NSString *CellIdentifier = @"STBoardCommentIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    STBoardCommentView *reuse = (STBoardCommentView *) [cell.contentView viewWithTag:100];
    [reuse prepareForReuse];
        [_overlord getCommentAndUserForToken:_currentToken andPosition:_numberOfCommentsForToken - indexPath.row-1 completion:^(STBoardComment *comment, STUser *user){
            if (_viewAppearing) {
                UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
                STBoardCommentView *commentView = (STBoardCommentView *) [currentCell.contentView viewWithTag:100];
                commentView.delegate = self;
                [commentView populateWithComment:comment andUser:user];
                NSNumber *position = @(indexPath.row);
                if (!_heightsDictionary[position]) {
                    [self setHeight:commentView.cellHeight forPosition:position];
                    //[tableView reloadData];
                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }error:^(NSError *error){
            
        }];
    return cell;
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
        return [self getHeaderCellFromTableView:tableView];
    }else {
        return [self getCommentCellFromTableView:tableView andIndexPath:indexPath];
    }
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
#pragma mark - Callbacks
- (void) stickerPickerSelectionDidChange:(STStickerPickerView *)stickerPicker {
    self.selectedStickers = stickerPicker.selectedStickers;
    [self refreshData:nil];
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
                [self refreshData:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error on comment post"delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }
        };
        vc.overlordToken = _currentToken;
        vc.place = self.place;
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"logInSegue" sender:sender];
    }
}
- (void) navigateUsingGoogleMapsFromLocation:(STLocation *) source toLocation:(STLocation *) destination {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        if (source) {
            NSString  *url = [NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=driving",source.locationCoordinate.latitude,source.locationCoordinate.longitude,destination.locationCoordinate.latitude,destination.locationCoordinate.longitude];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }else{
            NSString  *url = [NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=driving",destination.locationCoordinate.latitude,destination.locationCoordinate.longitude];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/id585027354"]];
    }
}
- (void) navigateUsingAppleMapsFromLocation:(STLocation *) source toLocation:(STLocation *) destination {
    NSString* urlStr;
    NSString* saddr = @"Current+Location";
    NSString *daddr = [NSString stringWithFormat:@"%f,%f", destination.locationCoordinate.latitude,destination.locationCoordinate.longitude];
    CLLocationCoordinate2D currentLocation = source.locationCoordinate;
    
    if (source) {
        //Valid location.
        saddr = [NSString stringWithFormat:@"%f,%f", currentLocation.latitude,currentLocation.longitude];

        urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%@&daddr=%@", saddr, daddr];
    } else {
        //Invalid location. Location Service disabled.
        urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%@", daddr];
    }

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}
- (void) navigateUsingWazeToLocation:(STLocation *) location {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"waze://"]]) {
        NSString *urlStr = [NSString stringWithFormat:@"waze://?ll=%f,%f&navigate=yes", location.locationCoordinate.latitude, location.locationCoordinate.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/id323229106"]];
    }
}
- (IBAction)directionsButtonPressed:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Which app do you want to use?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Waze",@"Google Maps",@"Apple Maps", nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
}
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    STLocation *source = [STHiveCluster spawnOverlord].userLocation;
    STLocation *destination = self.place.location;
    switch (buttonIndex) {
        case 0:
            [self navigateUsingWazeToLocation:self.place.location];
            break;
        case 1:
            [self navigateUsingGoogleMapsFromLocation:source toLocation:destination];
            break;
        case 2:
            [self navigateUsingAppleMapsFromLocation:source toLocation:destination];
            break;
        default:
            break;
    }
}
- (void) refreshView:(UIRefreshControl *) refresh {
    [self refreshData:^(BOOL completed) { 
        if (completed) {
            [refresh endRefreshing];
        }else{
            [refresh endRefreshing];
        }
    }];
}
- (BOOL) swipeViewShouldSwipe:(STSwipeView *)swipeView {
    if (_overlord.user) {
        return YES;
    }else{
        return NO;
    }
}
- (void) swipeViewDidSwipeRight:(STSwipeView *)swipeView {
    STBoardCommentView *commentView = (STBoardCommentView *)swipeView;
    STBoardComment *comment = commentView.currentComment;
    [_overlord likeComment:comment completion:^(STBoardComment *comment) {
        NSLog(@"Liked a comment");
    } error:^(NSError *error) {
        NSLog(@"Error on like: %@", error);
    }];
}
- (void) swipeViewDidSwipeLeft:(STSwipeView *)swipeView{
    STBoardCommentView *commentView = (STBoardCommentView *)swipeView;
    STBoardComment *comment = commentView.currentComment;
    [_overlord dislikeComment:comment completion:^(STBoardComment *comment) {
        NSLog(@"Disliked a comment");
    } error:^(NSError *error) {
        NSLog(@"Error on dislike: %@", error);
    }];
}
@end
