//
//  STProfileViewController.m
//  Stig
//
//  Created by Lucas Tenório on 21/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STProfileViewController.h"
#import "STOverlord.h"
#import "STBoardViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation STProfileViewController {
    id<STOverlord> _overlord;
    NSLock * _lock;
    BOOL _loading;
    NSArray * _placeID;
    NSCache * _places;
    NSUInteger _checkinCount;
    NSUInteger _pageCount;
    NSUInteger _lastPage;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    _overlord = [STHiveCluster spawnOverlord];
    if (!self.user) {
        self.user = _overlord.user;
    }
    [super viewDidLoad];
    _placeID = [NSArray array];
    _lock = [[NSLock alloc] init];
    _places = [[NSCache alloc] init];
    _checkinCount = 0;
    _pageCount = 0;
    _lastPage = 0;
    [self.userImage.layer setCornerRadius:5.0];
    [self.userImage.layer setMasksToBounds:YES];


    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Futura" size:20.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Perfil";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.customNavigationItem.titleView = label;
    self.userLabel.text = self.user.userName;
    self.pointsLabel.text = [NSString stringWithFormat:@"%@ pontos", self.user.points];
    [self.pointsLabel sizeToFit];
    [self.userImage setImageWithURL:[NSURL URLWithString:self.user.userImageURL]];

    [self refreshData:nil];
}

- (void) refreshData:(void(^)(BOOL completed))completion {
    [_overlord getCheckInHistoryPlacesInPage:1 forUser:self.user completion:^(NSArray *places, NSArray *dates, NSUInteger count, NSUInteger pages) {
        if(count == _checkinCount){
            if(completion) completion(YES);
        } else{
            _checkinCount = count;
            _pageCount = pages;
            
            for(int i = 0; i < places.count; i++){
                NSNumber * number = places[i];
                [_overlord resolvePlaceById:number completion:^(STPlace *place) {
                    [_places setObject:place forKey:place.placeId];
                } error:^(NSError *error) {
                    NSLog(@"ERROR %@", error);
                }];
            }
            _placeID = places;
            _lastPage = 1;
            [self.tableView reloadData];
        }
    } error:^(NSError *error) {
        NSLog(@"ERROR: %@", error);
    }];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    STBoardViewController *vc =  (STBoardViewController *)segue.destinationViewController;
    vc.place = sender;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _checkinCount;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckinCellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CheckinCellIdentifier"];
    }
    [cell.textLabel setText:@"Carregando"];
    cell.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
    if(indexPath.row < _placeID.count){
        NSNumber * pId = _placeID[indexPath.row];
        STPlace * _place = [_places objectForKey:pId];
        if(_place){
            [cell.textLabel setText:_place.placeName];
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
        } else{
            [_overlord resolvePlaceById:pId completion:^(STPlace *place) {
                [_places setObject:place forKey:place.placeId];
                UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
                currentCell.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
                [currentCell.textLabel setText:place.placeName];
                [currentCell setNeedsLayout];
                [currentCell layoutIfNeeded];
            } error:^(NSError *error) {
                NSLog(@"ERROR %@", error);
            }];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row < _placeID.count){
        NSNumber * pID = _placeID[indexPath.row];
        STPlace * place = [_places objectForKey:pID];
        if(place){
            [self performSegueWithIdentifier:@"HistoryToBoardSegue" sender:place];
        }
    }
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row > _placeID.count){
        [_lock lock];
        if(_loading){
            [_lock unlock];
            return;
        } else{
            _loading = YES;
            [_lock unlock];
        }
        [_overlord getCheckInHistoryPlacesInPage:_lastPage+1 forUser:self.user completion:^(NSArray *places, NSArray *dates, NSUInteger count, NSUInteger pages) {
            for(int i = 0; i < places.count; i++){
                NSNumber * number = places[i];
                [_overlord resolvePlaceById:number completion:^(STPlace *place) {
                    [_places setObject:place forKey:place.placeId];
                } error:^(NSError *error) {
                    NSLog(@"ERROR %@", error);
                }];
            }
            NSMutableArray * arr = [NSMutableArray arrayWithArray:_placeID];
            [arr addObjectsFromArray:places];
            [_lock lock];
            _lastPage++;
            _loading = NO;
            [_lock unlock];
            [self.tableView reloadData];
        } error:^(NSError *error) {
            NSLog(@"ERROR %@", error);
        }];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
