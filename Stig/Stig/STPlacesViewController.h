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
@interface STPlacesViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *places;
@property (nonatomic,readonly) BOOL showingMap;

@property (weak, nonatomic) IBOutlet CircularButtonDisposerView *buttonDisposer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dropperConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dropperLabel;
- (IBAction)stickerButtonPressed:(UIButton *)sender;
@property (nonatomic, readonly) BOOL showingDropper;
@end
