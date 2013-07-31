//
//  STPlacesMapViewController.m
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STPlacesMapViewController.h"

@interface STPlacesMapViewController ()

@end

@implementation STPlacesMapViewController {
    STPlace *_selectedPlace;
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

    [self.mapView setDelegate:self];
    [self.mapView addAnnotations:self.places];
    [self.mapView addOverlays:self.places];
    [self.mapView setRegion:[self regionFromAnnotations:self.places]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _rankingCriteria = ST_OVERALL;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
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
#pragma mark - MapView Delegate
- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [self.mapView setCenterCoordinate:[view.annotation coordinate] animated:YES];
    view.selected = NO;
    STPlace *place = (STPlace *)view.annotation;
    _selectedPlace = place;
    [self.calloutViewController showCalloutForPlace:place];
    if (self.delegate && [[self.delegate class] instancesRespondToSelector:@selector(placesMapViewController:placeSelected:)]) {
        [self.delegate placesMapViewController:self placeSelected:place];
    }
}
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSString * identifier = @"StigPin";

    MKAnnotationView *pin = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

    if(!pin){
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        //pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        //pin.image = [UIImage imageNamed:@"pino_40"];
        [((MKPinAnnotationView *)pin) setPinColor:MKPinAnnotationColorRed];
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return pin;
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
    NSLog(@"Region Will change animated: %d", animated);
    if (!animated) {
        for (id <MKAnnotation> a in self.mapView.selectedAnnotations) {
            [self.mapView deselectAnnotation:a animated:YES];
        }
        if (self.delegate && [[self.delegate class] instancesRespondToSelector:@selector(placesMapViewControllerMapDidMove:)]) {
            [self.delegate placesMapViewControllerMapDidMove:self];
        }
    }
}
- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"Deselected!");
}
- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    if([overlay isKindOfClass: [STPlace class]]){
        return [[STMapOverlayView alloc] initWithOverlay:overlay];
    }
    return nil;
}
@end
