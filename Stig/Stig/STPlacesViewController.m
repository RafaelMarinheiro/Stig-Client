//
//  STPlacesViewController.m
//  PJPrototype
//
//  Created by Lucas Tenório on 22/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STPlacesViewController.h"
#import "STBoardViewController.h"
#import "STMapOverlayView.h"

@interface STPlacesViewController ()

@end



@implementation STPlacesViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    _showingMap = YES;
    _showingDropper = NO;
    self.buttonDisposer.disposeToTheRight = NO;
    if (!self.places) {
        STOverlord *overlord = [STOverlord sharedInstance];
        [overlord getPlacesWithSearchTerm:@"" pageNumber:0 completion:^(NSArray *places, NSUInteger pageNumber){
            self.places = places;
            [self sortPlaces];
            [self.mapView setDelegate:self];
            [self.mapView addAnnotations:self.places];
            [self.mapView addOverlays:self.places];
            [self.mapView setRegion:[self regionFromAnnotations:self.places]];
            [self.tableView reloadData];
        }error:^(NSError *error) {
            NSLog(@"ERROR LOADING PLACES DATA !");
        }];
    }
    
    
    self.buttonDisposer.callback = ^(NSUInteger tag) {
        STRankingCriteria crit;
        if(tag == 0){
            crit = ST_SOCIAL;
        } else if(tag == 2){
            crit = ST_BUZZ;
        } else{
            crit = ST_OVERALL;
        }
        if([STMapOverlayView criteria] != crit){
            [STMapOverlayView setCriteria:crit];
            for (id st in [self.mapView overlays]) {
                if([st isKindOfClass:[STPlace class]]){
                    id view = [self.mapView viewForOverlay:st];
                    [view setNeedsDisplay];
                }
                
            }
        }

    };
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Dropper Movement

- (void) showDropper {
    if (!self.showingDropper) {
        [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dropperConstraint.constant = 5.0;
            [self.view layoutIfNeeded];
        }completion:^(BOOL completed){
            [UIView animateWithDuration:0.1 animations:^{
                self.dropperConstraint.constant = 0.0;
                [self.view layoutIfNeeded];
            }completion:^(BOOL completed){

            }];
        }];
        _showingDropper = YES;
    }
    
}
-(void) hideDropper {
    if (self.showingDropper) {
        [UIView animateWithDuration:0.20 animations:^{
            self.dropperConstraint.constant = -100.0;
            [self.view layoutIfNeeded];
        }];
        _showingDropper = NO;
    }
}

#pragma mark - MapView Delegate
- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [self.mapView setCenterCoordinate:[view.annotation coordinate] animated:YES];
    view.selected = NO;
    STPlace *place = (STPlace *)view.annotation;
    [self.dropperLabel setText:place.placeName];
    [self showDropper];
}
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSString * identifier = @"Pin";
    MKAnnotationView *pin =(MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

    if (!pin){
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        ((MKPinAnnotationView *)pin).pinColor = MKPinAnnotationColorPurple;
        //pin.canShowCallout = YES;
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return pin;
}
- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    STPlace *place = (STPlace *) view.annotation;
    [self pushBoardViewControllerWithPlace:place];
}
- (MKCoordinateRegion) regionFromAnnotations:(NSArray *) annotations{
    id <MKAnnotation> first = annotations[0];
    CLLocationDegrees maxLongitude = first.coordinate.longitude;
    CLLocationDegrees minLogitude = first.coordinate.longitude;
    CLLocationDegrees maxLatitude = first.coordinate.latitude;
    CLLocationDegrees minLatitude = first.coordinate.latitude;


    for (id <MKAnnotation> annotation in annotations) {
        if (annotation.coordinate.latitude < minLatitude) {
            minLatitude = annotation.coordinate.latitude;
        }

        if (annotation.coordinate.latitude > maxLatitude) {
            maxLatitude = annotation.coordinate.latitude;
        }

        if (annotation.coordinate.longitude < minLogitude) {
            minLogitude = annotation.coordinate.longitude;
        }
        if (annotation.coordinate.longitude > maxLongitude) {
            maxLongitude = annotation.coordinate.longitude;
        }
    }

    CLLocationDegrees deltaLatitude = maxLatitude - minLatitude;

    CLLocationDegrees deltaLongitude = maxLongitude - minLogitude;
    CLLocationDegrees latitude = deltaLatitude/2.0  + minLatitude;
    CLLocationDegrees longitude = deltaLongitude/2.0 + minLogitude;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateSpan s = MKCoordinateSpanMake(deltaLatitude + 0.02, deltaLongitude + 0.02);
    return MKCoordinateRegionMake(coordinate, s);
}
- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (!animated) {
        [self hideDropper];
    }
}

#pragma mark - MapOverlay Delegate Methods

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    if([overlay isKindOfClass: [STPlace class]]){
        return [[STMapOverlayView alloc] initWithOverlay:overlay];
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.places) {
        return [self.places count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Teste";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    STPlace *place = self.places[indexPath.row];
    cell.textLabel.text = place.placeName;
    cell.detailTextLabel.text = place.placeDescription;
    cell.contentView.backgroundColor = [self colorForRanking:place.ranking];
    // Configure the cell...
    
    return cell;
}
- (void) sortPlaces {
    NSArray *sorted  = [self.places sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
        if ([a isKindOfClass:[STPlace class]] && [b isKindOfClass:[STPlace class]]){
            
            STPlace *first = a;
            STPlace *second = b;
            float left = [first.ranking.overall floatValue];
            float right = [second.ranking.overall floatValue];
            if (left < right) {
                return NSOrderedDescending;
            }else if (left == right){
                return NSOrderedSame;
            } else {
                return NSOrderedAscending;
            }
        } else {
            
        }
        return NSOrderedSame;
    }];
    self.places = sorted;
}
- (UIColor *) colorForRanking:(STRanking *) ranking {
    UIColor *baseColor = [UIColor colorWithRed:114.0/255.0 green:73.0/255.0 blue:227.0/255.0 alpha:1.0];
    CGFloat alpha = [ranking.overall floatValue]/1000.0 + 0.2;
    return [baseColor colorWithAlphaComponent:alpha];
}

#pragma mark - Table view delegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    [self pushBoardViewControllerWithPlace:self.places[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)switchViews:(UIBarButtonItem *)sender {
    if (self.showingMap) {
        [UIView transitionFromView:self.mapView toView:self.tableView duration:0.7 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionCurlUp completion:nil];

        _showingMap = NO;
    } else {
        [UIView transitionFromView:self.tableView toView:self.mapView duration:0.7 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionCurlDown
                        completion:nil];

        _showingMap = YES;
    }

}
#pragma mark - Pushing View Controller
- (void) pushBoardViewControllerWithPlace:(STPlace *)place {
    STBoardViewController *viewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"STBoardViewControllerID"];
    viewController.place = place;
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
