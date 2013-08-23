//
//  STPlacesListViewController.m
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STPlacesListViewController.h"
#import "STBoardViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "STDraggerViewController.h"

@implementation STPlacesListViewController {
    id <STOverlord> _overlord;
    NSUInteger _numberOfPlaces;
    BOOL _loadedPlaces;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) setPlaces:(NSArray *)places {
    _places = places;
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _loadedPlaces = NO;
    STAppDelegate *app = (STAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app addObserver:self forKeyPath:@"currentSearchToken" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setOverlordToken:(STOverlordToken)overlordToken {
    _overlordToken = overlordToken;
    [self reloadPlaces];
}
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSNumber *test = change[NSKeyValueChangeNewKey];
    self.overlordToken = [test integerValue];
}
- (void) reloadPlaces {
    _loadedPlaces = NO;
    _overlord = [STHiveCluster spawnOverlordWithType:STOverlordTypeNetworked];
    NSLog(@"LIST TOKEN !%d", _overlordToken);
    [_overlord getNumberOfPlacesForToken:_overlordToken completion:^(NSUInteger numberOfPlaces) {
        _numberOfPlaces = numberOfPlaces;
        _loadedPlaces = YES;
        //_loadedIndexPath = [NSMutableDictionary dictionaryWithCapacity:numberOfPlaces];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
    }];
}
#pragma mark - Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (_loadedPlaces) {
            return _numberOfPlaces;
        }
    }
    return 0;
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    STPlace *place = self.places[path.row];
    STBoardViewController *vc = segue.destinationViewController;
    vc.place = place;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell *cell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:@"searchresultscell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchresultscell"];
            return cell;
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
    [_overlord getPlaceForToken:_overlordToken andPosition:indexPath.row completion:^(STPlace *place) {
       
        UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:indexPath];
        currentCell.selectionStyle = UITableViewCellSelectionStyleGray;
        [currentCell.textLabel setFont:[UIFont fontWithName:@"Futura" size:16.0]];
        [currentCell.textLabel setBackgroundColor:[UIColor clearColor]];
        [currentCell.textLabel setText:place.placeName];
        [currentCell.textLabel setTextColor:[UIColor whiteColor]];
        [currentCell setNeedsLayout];
    } error:^(NSError *error) {
        
    }];
    return cell;
}
#pragma mark - Table View Delegate Methods
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nav =(UINavigationController *) self.mm_drawerController.centerViewController;
    STDraggerViewController *dragger =(STDraggerViewController *) nav.topViewController;
    [_overlord getPlaceForToken:_overlordToken andPosition:indexPath.row completion:^(STPlace *place) {
        [dragger.mapViewController selectPlace:place];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];

    } error:^(NSError *error) {
        
    }];
}



- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self.mm_drawerController setMaximumLeftDrawerWidth:320.0 animated:YES completion:nil];
}
- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self.mm_drawerController setMaximumLeftDrawerWidth:240.0 animated:YES completion:nil];
}
- (void) dealloc {
    STAppDelegate *app = (STAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app removeObserver:self forKeyPath:@"currentSearchToken"];
}
@end
