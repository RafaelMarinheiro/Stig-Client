//
//  STDraggerViewController.h
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STCalloutViewController.h"
#import "STPlacesMapViewController.h"



typedef enum {
    STDraggerStateHidden,
    STDraggerStateShowing,
    STDraggerStateDragging,
    STDraggerStateAnimating
} STDraggerState;

@interface STDraggerViewController : UIViewController <STPlacesMapViewControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceConstraint;
@property (nonatomic, strong) UIPanGestureRecognizer *dragGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *draggedView;
@property (nonatomic) STDraggerState state;
- (IBAction)toggleDragger:(id)sender;
- (void) toggleShowingDragger;
- (void) showDraggerWithCompletion:(void (^)(BOOL completed) )completion;
- (void) hideDraggerWithCompletion:(void (^)(BOOL completed) )completion;

@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) STCalloutViewController *calloutViewController;
@property (nonatomic, strong) STPlacesMapViewController *mapViewController;
@end
