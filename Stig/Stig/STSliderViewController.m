//
//  STPlacesViewController.m
//  PJPrototype
//
//  Created by Lucas Tenório on 22/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STSliderViewController.h"
#import "STBoardViewController.h"
#import "STMapOverlayView.h"
#import <QuartzCore/QuartzCore.h>

#import <FacebookSDK/FacebookSDK.h>

@interface STSliderViewController ()
    
@end



@implementation STSliderViewController
- (void)viewDidLoad

{

    [FBSession.activeSession openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
            completionHandler:^(FBSession *session,
                                FBSessionState status,
                                NSError *error) {
                if ([FBSession.activeSession isOpen]) {
                    [[FBRequest requestForMe] startWithCompletionHandler:
                     ^(FBRequestConnection *connection,
                       NSDictionary<FBGraphUser> *user,
                       NSError *error) {
                         if(!error){
                             NSLog([[FBSession.activeSession accessTokenData] accessToken]);
                         }
                     }];
                }
            }];
    



    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
    [button addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //[self.customNavigationBar.items[0] setLeftBarButtonItem:barButtonItem];
    _showingDrawer = NO;
    self.drawerGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrawerPan:)];
    self.drawerGestureRecognizer.enabled = NO;
    self.closeDrawerGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.closeDrawerGestureRecognizer.enabled = NO;
    [self.mapViewContainer addGestureRecognizer:self.drawerGestureRecognizer];
    [self.mapViewContainer addGestureRecognizer:self.closeDrawerGestureRecognizer];
    [super viewDidLoad];
    if (!self.places) {
        id<STOverlord> overlord = [STHiveCluster spawnOverlord];
        [overlord getPlacesWithSearchTerm:nil pageNumber:0 completion:^(NSArray *places, NSUInteger pageNumber){
            self.places = places;
        } error:^(NSError *error) {
            NSLog(@"ERROR LOADING PLACES DATA !");
        }];
    }
}
- (void) viewDidLayoutSubviews {
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) setPlaces:(NSArray *)places {
    _places = places;
    if (self.listViewController) {
        self.listViewController.places = _places;
    }
    if (self.draggerViewController) {
        self.draggerViewController.places = _places;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Dragger Segue"]) {
        self.draggerViewController = segue.destinationViewController;
        self.draggerViewController.delegate = self;
    }else if ([segue.identifier isEqualToString:@"List Segue"]){
        self.listViewController= segue.destinationViewController;
    }
}
#pragma mark - Pushing View Controller
- (void) pushBoardViewControllerWithPlace:(STPlace *)place {
    STBoardViewController *viewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"STBoardViewControllerID"];
    viewController.place = place;
    [self.navigationController pushViewController:viewController animated:YES];
}
#pragma mark - Drawer Movement
- (CGFloat) drawerInitialConstant {
    return self.view.frame.size.width - 60.0;
}
- (void) handleTap:(UITapGestureRecognizer *) recognizer {
    [self hideDrawer];
}

- (void) handleDrawerPan:(UIPanGestureRecognizer *) recognizer {
    CGPoint translation = [recognizer translationInView:self.draggerViewController.view];
    self.drawerConstraint.constant = MAX(0.0, [self drawerInitialConstant] + translation.x);
    if (recognizer.state ==  UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat distanceToShow = abs(self.drawerConstraint.constant  - [self drawerInitialConstant]);
        if (distanceToShow < self.drawerConstraint.constant) {
            [self showDrawer];
        }else {
            [self hideDrawer];
        }
    }
}
- (void) showDrawer {
    self.drawerGestureRecognizer.enabled = YES;
    self.closeDrawerGestureRecognizer.enabled = YES;
    [self.draggerViewController.view setUserInteractionEnabled:NO];
    
    CGFloat constant = self.view.frame.size.width - 60.0;
    self.drawerConstraint.constant = constant;
    _showingDrawer = YES;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];    
    }];
}
- (void) hideDrawer {
    self.drawerGestureRecognizer.enabled = NO;
    self.closeDrawerGestureRecognizer.enabled = NO;
    [self.draggerViewController.view setUserInteractionEnabled:YES];
    
    self.drawerConstraint.constant = 0;
    _showingDrawer = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (void) leftButtonPressed:(id) sender {
    if (!self.showingDrawer) {
        [self showDrawer];
    } else {
        [self hideDrawer];
    }
}
#pragma mark - Dragger View Controller Delegate
- (void) draggerViewControllerSliderButtonPressed:(STDraggerViewController *)draggerViewController {
    if (!self.showingDrawer) {
        [self showDrawer];
    } else {
        [self hideDrawer];
    }
}
@end
