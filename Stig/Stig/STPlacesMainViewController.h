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
@property (nonatomic) BOOL showingDrawer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drawerConstraint;
@property (nonatomic, strong) UIPanGestureRecognizer *drawerGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *closeDrawerGestureRecognizer;
@end
