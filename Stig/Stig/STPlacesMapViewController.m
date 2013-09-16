//
//  STPlacesMapViewController.m
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STPlacesMapViewController.h"
#import "STConfigViewController.h"
#import "STProfileViewController.h"
#import "STOverlord.h"
#import "STPlacesListViewController.h"
#import "UIViewController+MMDrawerController.h"
@interface STPlacesMapViewController ()

@end

@implementation STPlacesMapViewController {
    STPlace *_selectedPlace;
    STOverlordToken _overlordToken;
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
    BOOL _locationLoaded;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (STPlace *) selectedPlace {
    return _selectedPlace;
}
- (void) setPlaces:(NSArray *)places {
    _places = places;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView setDelegate:self];
    [self.mapView addAnnotations:self.places];
    [self.mapView addOverlays:self.places];
    [self.mapView setRegion:[self regionFromAnnotations:self.places]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _locationLoaded = NO;
    _rankingCriteria = ST_OVERALL;

    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self.filterDisposerView.mainButton setImage:[UIImage imageNamed:@"filter_yellow_50"] forState:UIControlStateNormal];
    [self.filterDisposerView.buttons[0] setImage:[UIImage imageNamed:@"filter-intercalation"] forState:UIControlStateNormal];
    [self.filterDisposerView.buttons[1] setImage:[UIImage imageNamed:@"filter-buzz-44"] forState:UIControlStateNormal];
    [self.filterDisposerView.buttons[2] setImage:[UIImage imageNamed:@"filter-social-44"] forState:UIControlStateNormal];
    self.filterDisposerView.delegate = self;

    [self.optionsDisposerView.mainButton setImage:[UIImage imageNamed:@"plus_yellow_50.png"] forState:UIControlStateNormal];
    [self.optionsDisposerView.buttons[0] setImage:[UIImage imageNamed:@"plus-config-44.png"] forState:UIControlStateNormal];
    [self.optionsDisposerView.buttons[1] setImage:[UIImage imageNamed:@"plus-historico-44.png"] forState:UIControlStateNormal];
    [self.optionsDisposerView.buttons[2] setImage:[UIImage imageNamed:@"plus-me-44.png"] forState:UIControlStateNormal];
    self.optionsDisposerView.delegate = self;
    self.optionsDisposerView.shouldRotateMainButton = YES;
    self.optionsDisposerView.disposeToTheRight = NO;
    [self loadPlaces];
    [self startLocationServices];
}

- (void) startLocationServices {
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location" message:@"You should enable the location services so we can help you find the best place to go!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [alert show];
    }
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startMonitoringSignificantLocationChanges];
    
}
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _currentLocation = locations[0];
    [[STHiveCluster spawnOverlord] setUserLocation:[STLocation locationFromCLLocationCoordinate2D:_currentLocation.coordinate]];
    NSLog(@"Location update : %@", _currentLocation);
    if (!_locationLoaded) {
        _locationLoaded = YES;
        [self centerMapOnLocation:_currentLocation.coordinate];
    }
}
- (void) loadPlaces {
    id <STOverlord> overlord = [STHiveCluster spawnOverlord];
    _overlordToken = [overlord requestTokenForPlacesWithSearchTerm:nil];
    [overlord getNumberOfPlacesForToken:_overlordToken completion:^(NSUInteger numberOfPlaces) {
        for (int i =0; i < numberOfPlaces; i++) {
            [overlord getPlaceForToken:_overlordToken andPosition:i completion:^(STPlace *place) {
                [self.mapView addAnnotation:place];
                [self.mapView addOverlay:place];
            } error:^(NSError *error) {
                NSLog(@"Error loading place %@", error);
            }];
        }
    } error:^(NSError *error) {
        NSLog(@"Error loading places %@", error);
    }];
    STPlacesListViewController *vc = (STPlacesListViewController *)self.mm_drawerController.leftDrawerViewController;
    vc.overlordToken = _overlordToken;
    NSLog(@"%@ %@",self.mm_drawerController,vc);
    STAppDelegate *app = (STAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.currentSearchToken = _overlordToken;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)suggestionButtonPressed:(id)sender {
    double k = -1;

    for(int i = 0; i < [self.mapView.annotations count]; i++){
        STPlace * place = [self.mapView.annotations objectAtIndex: i];
        if([place isKindOfClass: [STPlace class]]){
            if([place.ranking.buzz floatValue] + [place.ranking.social floatValue] > k){
                k = [place.ranking.buzz floatValue] + [place.ranking.social floatValue];
                _selectedPlace = place;
            }
        }
    }

    if (k != -1){
        [self selectPlace:_selectedPlace];
    }
}
- (void) centerMapOnLocation:(CLLocationCoordinate2D) location {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}
- (void) selectPlace:(STPlace *) place {
    _selectedPlace = place;
    [self.mapView selectAnnotation:place animated:NO];
    [self centerMapOnLocation:_selectedPlace.coordinate];
}
#pragma mark - Setters

- (void) setRankingCriteria:(STRankingCriteria)rankingCriteria {
    _rankingCriteria = rankingCriteria;
    
    if([STMapOverlayView criteria] != rankingCriteria){
        [STMapOverlayView setCriteria:rankingCriteria];
        for (id st in [self.mapView overlays]) {
            if([st isKindOfClass:[STPlace class]]){
                id view = [self.mapView viewForOverlay:st];
                [view setNeedsDisplay];
            }
        }
    }
}
#pragma mark - Circular Disposer Delegate
- (void) circularButtonDisposerViewWillDispose:(CircularButtonDisposerView *)disposer {
    if (self.filterDisposerView == disposer) {
        [UIView animateWithDuration:0.25 animations:^{
            self.optionsDisposerView.alpha = 0.2;
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            self.filterDisposerView.alpha = 0.2;
        }];
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.suggestionButton.alpha = 0.2;
    }];
}
- (void) circularButtonDisposerViewWillHide:(CircularButtonDisposerView *)disposer {
    [UIView animateWithDuration:0.25 animations:^{
        self.filterDisposerView.alpha = 1.0;
        self.optionsDisposerView.alpha = 1.0;
        self.suggestionButton.alpha = 1.0;
    }];
}
- (void) circularButtonDisposerView:(CircularButtonDisposerView *)disposer buttonPressed:(NSUInteger)buttonTag {
    if (disposer == self.filterDisposerView) {
        STRankingCriteria crit;
        if(buttonTag == 0){
            crit = ST_OVERALL;
        } else if(buttonTag == 1){
            crit = ST_BUZZ;
        } else{
            crit = ST_SOCIAL;
        }
        [self setRankingCriteria:crit];
    }else {
        id <STOverlord> overlord = [STHiveCluster spawnOverlord];
        if (overlord.user) {
            if (buttonTag == 0) {
                [self performSegueWithIdentifier:@"settingsSegue" sender:nil];
            }else if (buttonTag == 2) {
                [self performSegueWithIdentifier:@"profileSegue" sender:nil];
            }
        } else {
            [self performSegueWithIdentifier:@"logInMapSegue" sender:nil];
        }
        
    }
}
#pragma mark - MapView Delegate
- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[STPlace class]]) {
        [self.mapView setCenterCoordinate:[view.annotation coordinate] animated:YES];
        view.selected = NO;
        STPlace *place = (STPlace *)view.annotation;
        _selectedPlace = place;
        [self.calloutViewController showCalloutForPlace:place];
        if (self.delegate && [[self.delegate class] instancesRespondToSelector:@selector(placesMapViewController:placeSelected:)]) {
            [self.delegate placesMapViewController:self placeSelected:place];
        }
    }
}
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[STPlace class]]) {
        NSString * identifier = @"StigPin";

        MKAnnotationView *pin = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

        if(!pin){
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            [((MKPinAnnotationView *)pin) setPinColor:MKPinAnnotationColorRed];
            //pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            //pin.image = [UIImage imageNamed:@"icon_pin"];
            
        }
        return pin;
    }
    return nil;
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
        for (id <MKAnnotation> a in self.mapView.selectedAnnotations) {
            [self.mapView deselectAnnotation:a animated:YES];
        }
        if (self.delegate && [[self.delegate class] instancesRespondToSelector:@selector(placesMapViewControllerMapDidMove:)]) {
            [self.delegate placesMapViewControllerMapDidMove:self];
        }
    }
}
- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    if([overlay isKindOfClass: [STPlace class]]){
        return [[STMapOverlayView alloc] initWithOverlay:overlay];
    }
    return nil;
}
@end
