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
#import "NSString+Common.h"

@implementation STPlacesListViewController {
    id <STOverlord> _overlord;
    NSUInteger _numberOfPlaces;
    BOOL _loadedPlaces;



    NSOperationQueue *_searchQueue;
    NSArray * _searchResults;
    NSUInteger _numberOfResults;
}

- (NSArray *) appPlaces {
    STAppDelegate *app = (STAppDelegate *)[[UIApplication sharedApplication] delegate];
    return app.places;
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
    [super viewDidLoad];
    _loadedPlaces = NO;
    STAppDelegate *app = (STAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app addObserver:self forKeyPath:@"places" options:NSKeyValueObservingOptionNew context:nil];
    _searchQueue = [NSOperationQueue new];
    [_searchQueue setMaxConcurrentOperationCount:1];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) reloadPlaces {
    _loadedPlaces = NO;
}
#pragma mark - Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if(self.appPlaces){
            return [self.appPlaces count];
        }
    }
    if(_searchResults){
        return _searchResults.count;
    }
    return 0;
}
- (UITableViewCell *) searchCellforIndexPath:(NSIndexPath *) indexPath tableView:(UITableView *) tableView{
    UITableViewCell *cell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:@"searchresultscell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchresultscell"];
    }
    STPlace * place = _searchResults[indexPath.row];
    [cell.textLabel setText:place.placeName];
    return cell;
}
- (UITableViewCell *) placeCellForIndexPath:(NSIndexPath *) indexPath tableView:(UITableView *) tableView{
    UITableViewCell *currentCell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];

    STPlace * place = [self.appPlaces objectAtIndex:indexPath.row];
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

    return currentCell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    STPlace *place = self.appPlaces[path.row];
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
        STPlace * place = [self.appPlaces objectAtIndex:indexPath.row];
        [dragger.mapViewController selectPlace:place];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    } else {
        UINavigationController *nav =(UINavigationController *) self.mm_drawerController.centerViewController;
        STDraggerViewController *dragger =(STDraggerViewController *) nav.topViewController;
        STPlace * place = [_searchResults objectAtIndex:indexPath.row];
        [dragger.mapViewController selectPlace:place];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.searchBar resignFirstResponder];
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
}
- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {

    if (![searchString isBlank]) {
        NSMutableArray * res = [NSMutableArray array];
            for(int i = 0; i < self.appPlaces.count; i++){
                STPlace * place = self.appPlaces[i];
                if([[[place.placeName lowercaseString] stringByStrippingWhitespace] contains:[[searchString lowercaseString] stringByStrippingWhitespace]]){
                    [res addObject:place];
                }
            }
            _searchResults = res;
           
        return YES;
    } else {
        _searchResults = [NSArray array];
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
