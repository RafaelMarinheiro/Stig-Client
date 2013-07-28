//
//  STPlacesViewController.h
//  PJPrototype
//
//  Created by Lucas Tenório on 22/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STOverlord.h"
#import "STMapOverlayView.h"
#import "CircularButtonDisposerView.h"
#import "STDropperView.h"

@interface STPlacesViewController : UIViewController <MKMapViewDelegate, CircularButtonDisposerDelegate, STDropperViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *places;
@property (nonatomic,readonly) BOOL showingMap;

@property (weak, nonatomic) IBOutlet UIButton *suggestionButton;
@property (weak, nonatomic) IBOutlet CircularButtonDisposerView *optionsButtonDisposer;
@property (weak, nonatomic) IBOutlet CircularButtonDisposerView *filterButtonDisposer;
@property (weak, nonatomic) IBOutlet UILabel *dropperLabel;
@property (weak, nonatomic) IBOutlet STDropperView *dropperView;
- (IBAction)stickerButtonPressed:(UIButton *)sender;
@property (nonatomic, readonly) BOOL showingDropper;
@end
