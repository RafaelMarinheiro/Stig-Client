//
//  STPlacesViewController.h
//  PJPrototype
//
//  Created by Lucas Tenório on 22/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STOverlord.h"
#import "CircularButtonDisposerView.h"
#import "STDropperView.h"
#import "STStickersView.h"
#import "STDraggerViewController.h"
#import "STPlacesMapViewController.h"
#import "STPlacesListViewController.h"

@interface STPlacesMainViewController : UIViewController <CircularButtonDisposerDelegate, STDraggerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *listViewContainer;

@property (weak, nonatomic) IBOutlet UIView *mapViewContainer;
@property (nonatomic, strong) NSArray *places;

@property (nonatomic, strong) STDraggerViewController *draggerViewController;
@property (nonatomic, strong)  STPlacesListViewController *listViewController;
@property (nonatomic,readonly) BOOL showingMap;
@property (nonatomic, readonly) BOOL showingDropper;

@property (weak, nonatomic) IBOutlet UIButton *suggestionButton;
@property (weak, nonatomic) IBOutlet CircularButtonDisposerView *optionsButtonDisposer;
@property (weak, nonatomic) IBOutlet CircularButtonDisposerView *filterButtonDisposer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *dropperLabel;
@property (weak, nonatomic) IBOutlet STDropperView *dropperView;
@property (weak, nonatomic) IBOutlet STStickersView *stickersView;

@property (weak, nonatomic) IBOutlet UIButton *listSwitcherButton;

- (IBAction)switcherButtonPressed:(UIButton *)sender;
- (IBAction)stickerButtonPressed:(UIButton *)sender;
@end
