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

    for(int i = 0; i < [self.places count]; i++){
        STPlace * place = [self.places objectAtIndex:i];
        if([place.ranking.buzz floatValue] + [place.ranking.social floatValue] > k){
            k = [place.ranking.buzz floatValue] + [place.ranking.social floatValue];
            _selectedPlace = place;
        }
    }
    [self selectPlace:_selectedPlace];
}
#pragma mark - Setters
- (void) selectPlace:(STPlace *) place {
    _selectedPlace = place;
    [self.mapView selectAnnotation:place animated:NO];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_selectedPlace.coordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}
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
        self.optionsDisposerView.alpha = 0.2;
    }else {
        self.filterDisposerView.alpha = 0.2;
    }
    self.suggestionButton.alpha = 0.2;
}
- (void) circularButtonDisposerViewWillHide:(CircularButtonDisposerView *)disposer {
    self.filterDisposerView.alpha = 1.0;
    self.optionsDisposerView.alpha = 1.0;
    self.suggestionButton.alpha = 1.0;
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
        if (buttonTag == 0) {
            STConfigViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"STConfig"];
            [self presentViewController:vc animated:YES completion:nil];
        }else if (buttonTag == 2) {
            STProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"STProfileViewController"];
            [self.navigationController pushViewController:vc animated:YES];
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
            //pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            //pin.image = [UIImage imageNamed:@"pin_intercalation"];
            [((MKPinAnnotationView *)pin) setPinColor:MKPinAnnotationColorRed];
            pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
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
