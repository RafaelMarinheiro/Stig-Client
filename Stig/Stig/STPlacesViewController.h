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
#import "STStickersView.h"

@interface STPlacesViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, CircularButtonDisposerDelegate, STDropperViewDelegate>

@property (nonatomic, strong) NSArray *places;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property (nonatomic,readonly) BOOL showingMap;
@property (nonatomic, readonly) BOOL showingDropper;

@property (weak, nonatomic) IBOutlet UIButton *suggestionButton;
@property (weak, nonatomic) IBOutlet CircularButtonDisposerView *optionsButtonDisposer;
@property (weak, nonatomic) IBOutlet CircularButtonDisposerView *filterButtonDisposer;
@property (weak, nonatomic) IBOutlet UILabel *dropperLabel;
@property (weak, nonatomic) IBOutlet STDropperView *dropperView;
@property (weak, nonatomic) IBOutlet STStickersView *stickersView;

@property (weak, nonatomic) IBOutlet UIButton *listSwitcherButton;

- (IBAction)switcherButtonPressed:(UIButton *)sender;
- (IBAction)stickerButtonPressed:(UIButton *)sender;
@end
