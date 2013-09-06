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



    NSOperationQueue *_searchQueue;
    STOverlordToken _searchToken;
    NSUInteger _numberOfResults;
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
    _searchQueue = [NSOperationQueue new];
    [_searchQueue setMaxConcurrentOperationCount:1];
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
    _overlord = [STHiveCluster spawnOverlord];
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
    if (_searchToken != 0) {
        return _numberOfResults;
    }
    return 0;
}
- (UITableViewCell *) searchCellforIndexPath:(NSIndexPath *) indexPath tableView:(UITableView *) tableView{
    UITableViewCell *cell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:@"searchresultscell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchresultscell"];
    }
    [_overlord getPlaceForToken:_searchToken andPosition:indexPath.row completion:^(STPlace *place) {
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        [currentCell.textLabel setText:place.placeName];
        [currentCell setNeedsLayout];
        [currentCell layoutIfNeeded];
    } error:^(NSError *error){NSLog(@"Error loading searchResult:%@", error);}];
    return cell;
}
- (UITableViewCell *) placeCellForIndexPath:(NSIndexPath *) indexPath tableView:(UITableView *) tableView{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
    cell.textLabel.text = @"Loading ...";
    [_overlord getPlaceForToken:_overlordToken andPosition:indexPath.row completion:^(STPlace *place) {
        UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:indexPath];
        currentCell.selectionStyle = UITableViewCellSelectionStyleGray;
        UIImage *placeIcon;
        if (place.mostRelevantSticker) {
            placeIcon = [place.mostRelevantSticker stickerIconWithPlace:@"selector"];
        }else{
            placeIcon = [UIImage imageNamed:@"icon_neutro_empty"];
        }
        [currentCell.imageView setImage:placeIcon];
        [currentCell.textLabel setFont:[UIFont fontWithName:@"Futura" size:16.0]];
        [currentCell.textLabel setBackgroundColor:[UIColor clearColor]];
        [currentCell.textLabel setText:place.placeName];
        [currentCell.textLabel setTextColor:[UIColor whiteColor]];
        [currentCell setNeedsLayout];
    } error:^(NSError *error) {

    }];
    return cell;
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
        return [self searchCellforIndexPath:indexPath tableView:tableView];
    }else{
        return [self placeCellForIndexPath:indexPath tableView:tableView];
    }
}
#pragma mark - Table View Delegate Methods
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        UINavigationController *nav =(UINavigationController *) self.mm_drawerController.centerViewController;
        STDraggerViewController *dragger =(STDraggerViewController *) nav.topViewController;
        [_overlord getPlaceForToken:_overlordToken andPosition:indexPath.row completion:^(STPlace *place) {
            [dragger.mapViewController selectPlace:place];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.mm_drawerController closeDrawerAnimated:YES completion:nil];

        } error:^(NSError *error) {
            
        }];
    } else {
        UINavigationController *nav =(UINavigationController *) self.mm_drawerController.centerViewController;
        STDraggerViewController *dragger =(STDraggerViewController *) nav.topViewController;
        [_overlord getPlaceForToken:_searchToken andPosition:indexPath.row completion:^(STPlace *place) {
            [self.searchDisplayController.searchBar resignFirstResponder];
            [dragger.mapViewController selectPlace:place];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        } error:^(NSError *error) {

        }];
    }
}
- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {

    if (![searchString isEqualToString:@""]) {
        [_searchQueue cancelAllOperations];
        [_searchQueue addOperationWithBlock:^{
            STOverlordToken newToken = [_overlord requestTokenForPlacesWithSearchTerm:searchString];
            [_overlord getNumberOfPlacesForToken:newToken completion:^(NSUInteger numberOfPlaces) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    _numberOfResults = numberOfPlaces;
                    _searchToken = newToken;
                    [self.searchDisplayController.searchResultsTableView reloadData];
                }];
            } error: ^ (NSError *error) {
                NSLog(@"Error requesting token: %@", error);
            }];
        }];
        return NO;
    } else {
        _searchToken = 0;
        return YES;
    }
}
- (void) searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
}
- (void) searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
}
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self.mm_drawerController setMaximumLeftDrawerWidth:320.0 animated:YES completion:nil];
}
- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self.mm_drawerController setMaximumLeftDrawerWidth:270.0 animated:YES completion:nil];
}
- (void) dealloc {
    STAppDelegate *app = (STAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app removeObserver:self forKeyPath:@"currentSearchToken"];
}
@end
