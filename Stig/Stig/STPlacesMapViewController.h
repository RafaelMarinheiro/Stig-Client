//
//  STPlacesMapViewController.h
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "STPlace.h"
#import "STMapOverlayView.h"
#import "STCalloutViewController.h"
#import "CircularButtonDisposerView.h"

@protocol STPlacesMapViewControllerDelegate;
@interface STPlacesMapViewController : UIViewController <MKMapViewDelegate, CircularButtonDisposerDelegate>
@property (nonatomic, weak) id <STPlacesMapViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) STCalloutViewController *calloutViewController;
@property (nonatomic) STRankingCriteria rankingCriteria;
@property (weak, nonatomic) IBOutlet CircularButtonDisposerView *filterDisposerView;
@property (weak, nonatomic) IBOutlet UIButton *suggestionButton;
@property (weak, nonatomic) IBOutlet CircularButtonDisposerView *optionsDisposerView;
- (IBAction)suggestionButtonPressed:(id)sender;
- (void) selectPlace:(STPlace *) place;
- (STPlace *) selectedPlace;
@end

@protocol STPlacesMapViewControllerDelegate <NSObject>

- (void) placesMapViewController:(STPlacesMapViewController *) placesMapViewController placeSelected:(STPlace *) place;
- (void) placesMapViewControllerMapDidMove:(STPlacesMapViewController *)placesMapViewController;

@end