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



@implementation STPlacesViewController {
    STPlace *_selectedPlace;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    _showingMap = YES;
    _showingDropper = NO;
    self.dropperView.delegate = self;
    self.filterButtonDisposer.delegate = self;
    self.optionsButtonDisposer.delegate = self;
    self.optionsButtonDisposer.disposeToTheRight = NO;
    self.optionsButtonDisposer.shouldRotateMainButton = YES;
    if (!self.places) {
        STOverlord *overlord = [STOverlord sharedInstance];
        [overlord getPlacesWithSearchTerm:@"" pageNumber:0 completion:^(NSArray *places, NSUInteger pageNumber){
            self.places = places;
            [self.mapView setDelegate:self];
            [self.mapView addAnnotations:self.places];
            [self.mapView addOverlays:self.places];
            [self.mapView setRegion:[self regionFromAnnotations:self.places]];
        }error:^(NSError *error) {
            NSLog(@"ERROR LOADING PLACES DATA !");
        }];
    }
    
    UIButton *filterMainButton = self.filterButtonDisposer.mainButton;
    NSArray *filterButtons = self.filterButtonDisposer.buttons;
    [filterMainButton setImage:[UIImage imageNamed:@"filter_yellow_50"] forState:UIControlStateNormal];
    [filterButtons[0] setImage:[UIImage imageNamed:@"filter-stiger-44"] forState:UIControlStateNormal];
    [filterButtons[1] setImage:[UIImage imageNamed:@"filter-buzz-44"] forState:UIControlStateNormal];
    [filterButtons[2] setImage:[UIImage imageNamed:@"filter-social-44"] forState:UIControlStateNormal];

    [self.suggestionButton addTarget:self action:@selector(suggestSomething:) forControlEvents:UIControlEventTouchUpInside];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) suggestSomething: (UIButton *) button{
    int suggestion = rand()%([self.places count]);
    
    STPlace * place = [self.places objectAtIndex:suggestion];
    _selectedPlace = place;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(place.coordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    
    [self.dropperLabel setText:place.placeName];
    [self showDropper];
    //[self pushBoardViewControllerWithPlace:place];
    NSLog(@"WOHOOOO");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DropperView Delegate Methods
- (void) dragStarted {
    [self collapseDisposers];
}
- (void) dragCancelled {

}
- (void) dragCompleted {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Checkin!" message:[NSString stringWithFormat:@"Checkin at: %@", _selectedPlace.placeName] delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
    [alert show];
}
- (void) dragMoveWithPercentage:(NSNumber *)percentage {
    
}
#pragma mark - Circular Disposer Delegate Methods
- (void) circularButtonDisposerViewWillHide:(CircularButtonDisposerView *)disposer {
    [self collapseDisposers];
}
- (void) circularButtonDisposerView:(CircularButtonDisposerView *)disposer buttonPressed:(NSUInteger)buttonTag {
    if (disposer == self.filterButtonDisposer) {
        [self filterPressed:buttonTag];
    } else {
        [self optionsPressed:buttonTag];
    }
}

- (void) circularButtonDisposerViewWillDispose:(CircularButtonDisposerView *)disposer {
    if (disposer == self.filterButtonDisposer) {
        [self filterDisposed];
    }else {
        [self optionsDisposed];
    }
}
#pragma mark - Disposer Buttons Pressed
- (void) optionsPressed:(NSUInteger) optionNumber {
    
}
- (void) filterPressed:(NSUInteger) filterNumber {
    STRankingCriteria crit;
    if(filterNumber == 0){
        crit = ST_OVERALL;
    } else if(filterNumber == 1){
        crit = ST_BUZZ;
    } else{
        crit = ST_SOCIAL;
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
}
#pragma mark - Disposer States
- (void) collapseDisposers {
    [self.suggestionButton setAlpha:1.0];
    [self.suggestionButton setUserInteractionEnabled:YES];
    if ([self.filterButtonDisposer isDisposing]) {
        [self.filterButtonDisposer toggleDispose];
    }
    [self.filterButtonDisposer setAlpha:1.0];
    [self.filterButtonDisposer setUserInteractionEnabled:YES];
    if ([self.optionsButtonDisposer isDisposing]) {
        [self.optionsButtonDisposer toggleDispose];
    }
    [self.optionsButtonDisposer setAlpha:1.0];
    [self.optionsButtonDisposer setUserInteractionEnabled:YES];
}
- (void) optionsDisposed {
    [self.suggestionButton setAlpha:0.2];
    [self.suggestionButton setUserInteractionEnabled:NO];
    if ([self.filterButtonDisposer isDisposing]) {
        [self.filterButtonDisposer toggleDispose];
    }
    [self.filterButtonDisposer setAlpha:0.2];
    [self.filterButtonDisposer setUserInteractionEnabled:NO];
    
}
- (void) filterDisposed {
    [self.suggestionButton setAlpha:0.3];
    [self.suggestionButton setUserInteractionEnabled:NO];
    if ([self.optionsButtonDisposer isDisposing]) {
        [self.optionsButtonDisposer toggleDispose];
    }
    [self.optionsButtonDisposer setAlpha:0.3];
    [self.optionsButtonDisposer setUserInteractionEnabled:NO];
}

#pragma mark - Dropper Movement

- (void) showDropper {
    if (!self.showingDropper) {
        [self.dropperView showBasicInformation:^(BOOL completed){
            _showingDropper = YES;
        }];
    }
}
-(void) hideDropper {
    if (self.showingDropper) {
        [self.dropperView hide: ^(BOOL completed){
            _showingDropper = NO;
        }];
    }
}

#pragma mark - MapView Delegate
- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [self.mapView setCenterCoordinate:[view.annotation coordinate] animated:YES];
    view.selected = NO;
    STPlace *place = (STPlace *)view.annotation;
    _selectedPlace = place;
    [self.dropperLabel setText:place.placeName];
    [self showDropper];
    [self collapseDisposers];
}
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSString * identifier = @"Pin";
    MKAnnotationView *pin =(MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

    if (!pin){
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        ((MKPinAnnotationView *)pin).pinColor = MKPinAnnotationColorPurple;
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
        [self collapseDisposers];
    }
}

#pragma mark - MapOverlay Delegate Methods

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    if([overlay isKindOfClass: [STPlace class]]){
        return [[STMapOverlayView alloc] initWithOverlay:overlay];
    }
    return nil;
}



#pragma mark - Pushing View Controller
- (void) pushBoardViewControllerWithPlace:(STPlace *)place {
    STBoardViewController *viewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"STBoardViewControllerID"];
    viewController.place = place;
    [self.navigationController pushViewController:viewController animated:YES];
}
- (IBAction)stickerButtonPressed:(UIButton *)sender {
    [self pushBoardViewControllerWithPlace:_selectedPlace];
}
@end
