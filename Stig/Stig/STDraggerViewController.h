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
@protocol STDraggerViewControllerDelegate;

@interface STDraggerViewController : UIViewController <STPlacesMapViewControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceConstraint;
@property (nonatomic, strong) UIPanGestureRecognizer *dragGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *draggedView;
@property (nonatomic) STDraggerState state;
@property (nonatomic, weak) id <STDraggerViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UINavigationItem *customNavigationItem;
- (IBAction)toggleDragger:(id)sender;
- (void) toggleShowingDragger;
- (void) showDraggerWithCompletion:(void (^)(BOOL completed) )completion;
- (void) hideDraggerWithCompletion:(void (^)(BOOL completed) )completion;
- (IBAction)drawerButtonPressed:(id)sender;

@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) STCalloutViewController *calloutViewController;
@property (nonatomic, strong) STPlacesMapViewController *mapViewController;
@end

@protocol STDraggerViewControllerDelegate <NSObject>
@optional
- (void) draggerViewControllerWillShowCallout:(STDraggerViewController *) draggerViewController;
- (void) draggerViewControllerDidShowCallout:(STDraggerViewController *) draggerViewController;
- (void) draggerViewControllerWillHideCallout:(STDraggerViewController *) draggerViewController;
- (void) draggerViewControllerDidHideCallout:(STDraggerViewController *) draggerViewController;
- (void) draggerViewControllerSliderButtonPressed:(STDraggerViewController *) draggerViewController;
@end
