//
//  STDraggerViewController.m
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STDraggerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"
#import <MapKit/MapKit.h>


//static CGFloat const STDraggerShowingHeight = 100.0;
//static CGFloat const STDraggerPercentageInitial = STDraggerShowingHeight + 50.0;
//static CGFloat const STDraggerPercentageFinal = STDraggerPercentageInitial + 130.0;
static CGFloat const STDraggerBounceDelta = 5.0;

//static CGFloat const STDraggerTotalHeight = 501.0;
@interface STDraggerViewController ()

@end

@implementation STDraggerViewController

- (CGFloat) showingHeight {
    return 100.0;
}
- (CGFloat) animationInitialHeight {
    return [self showingHeight] + 50.0;
}
- (CGFloat) animationFinalHeight {
    CGFloat totalFrameHeight = self.view.frame.size.height;
    return totalFrameHeight * 0.8;
}
- (CGFloat) animationPercentage {
    CGFloat constraintConstant = -self.verticalSpaceConstraint.constant;
    if (constraintConstant <= [self animationInitialHeight]) {
        return 0.0;
    }else if (constraintConstant >= [self animationFinalHeight]){
        return 1.0;
    }else {
        return (constraintConstant - [self animationInitialHeight]) / ([self animationFinalHeight] - [self animationInitialHeight]);
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) viewWillAppear:(BOOL)animated {
    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"barra_logostig"] forBarMetrics:UIBarMetricsDefault];
}
- (void) viewWillDisappear:(BOOL)animated {
    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"barra_topo_stig"] forBarMetrics:UIBarMetricsDefault];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"";
    _state = STDraggerStateHidden;
    self.dragGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                  initWithTarget:self action:@selector(respondToPanGesture:)];
    [self.draggedView addGestureRecognizer:self.dragGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Map Segue"]) {
        self.mapViewController = segue.destinationViewController;
        self.mapViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Callout Segue"]) {
        self.calloutViewController = segue.destinationViewController;
    }
}

- (void) setPlaces:(NSArray *)places {
    _places = places;
    if (self.mapViewController) {
    //    self.mapViewController.places = _places;
    }
}
- (void) placesMapViewControllerMapDidMove:(STPlacesMapViewController *)placesMapViewController {
    [self hideDraggerWithCompletion:nil];
}
- (void) placesMapViewController:(STPlacesMapViewController *)placesMapViewController placeSelected:(STPlace *)place {
    [self.calloutViewController showCalloutForPlace:place];
    [self showDraggerWithCompletion:nil];
    
}


- (IBAction)toggleDragger:(id)sender {
    [self toggleShowingDragger];
}
- (void)respondToPanGesture:(UIPanGestureRecognizer *)recognizer{
    CGPoint translation = [recognizer translationInView:self.view];
    if([recognizer state] == UIGestureRecognizerStateBegan){
        _state = STDraggerStateDragging;
    }
    if(_state == STDraggerStateDragging){
        if(translation.y < 0) {
            [self moveDraggerToShowingPositionWithCompletion:^(BOOL completed){
                [self.calloutViewController changeForPercentage:0.0];
            }];
        };

        self.verticalSpaceConstraint.constant = -(translation.y + [self showingHeight]);
        [self.view layoutIfNeeded];

        CGFloat percentage = [self animationPercentage];
        [self.calloutViewController changeForPercentage:percentage];
        if(percentage >= 1.0){
            [self moveDraggerToShowingPositionWithCompletion:^(BOOL completed){
                [self.calloutViewController changeForPercentage:0.0];
            }];
            [self draggerCompletedCheckin];

        } else if (([recognizer state] == UIGestureRecognizerStateEnded) || ([recognizer state] == UIGestureRecognizerStateCancelled)) {
            [self moveDraggerToShowingPositionWithCompletion:^(BOOL completed){
                [self.calloutViewController changeForPercentage:0.0];
            }];
        }
    }
}
- (void) toggleShowingDragger {
    if (self.state == STDraggerStateShowing) {
        [self hideDraggerWithCompletion:nil];
    } else if (self.state == STDraggerStateHidden) {
        [self showDraggerWithCompletion:nil];
    }
}
- (void) showDraggerWithCompletion:(void (^)(BOOL completed) )completion {
    if (self.state == STDraggerStateHidden) {
        _state = STDraggerStateAnimating;
        [self draggerWillShowCallout];
        [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.verticalSpaceConstraint.constant = -([self showingHeight] + STDraggerBounceDelta);
            [self.view layoutIfNeeded];
        }completion:^(BOOL completed){
            self.verticalSpaceConstraint.constant = -[self showingHeight];
            [UIView animateWithDuration:0.10 animations:^{
                [self.view layoutIfNeeded];
            }completion:^(BOOL completed){
                _state = STDraggerStateShowing;
                [self draggerDidShowCallout];
                if (completion) {
                    completion(completed);
                }
            }];
        }];
    }
}
- (void) hideDraggerWithCompletion:(void (^)(BOOL completed) )completion {
    if (self.state == STDraggerStateShowing) {
        _state = STDraggerStateAnimating;
        [self draggerWillHideCallout];
        [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.verticalSpaceConstraint.constant = 0.0;
            [self.view layoutIfNeeded];
        }completion:^(BOOL completed){
            _state = STDraggerStateHidden;
            [self draggerDidHideCallout];
            if (completion) {
                completion(completed);
            }
        }];
    }
}

- (IBAction)drawerButtonPressed:(id)sender {
    [self draggerSliderButtonPressed];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void) moveDraggerToShowingPositionWithCompletion:( void (^)(BOOL completed)) completion {
    if (self.state == STDraggerStateDragging) {
        _state = STDraggerStateAnimating;
        
        [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.verticalSpaceConstraint.constant = -([self showingHeight] - STDraggerBounceDelta);
            [self.view layoutIfNeeded];
        }completion:^(BOOL completed){
            self.verticalSpaceConstraint.constant = -[self showingHeight];
            [UIView animateWithDuration:0.10 animations:^{
                [self.view layoutIfNeeded];
            }completion:^(BOOL completed){
                _state = STDraggerStateShowing;
                if (completion) {
                    completion(completed);
                }
            }];
        }];
    }
}

- (double) distanceInMetersToPlace: (STPlace *) place{
    id<STOverlord> overlord = [STHiveCluster spawnOverlord];
    STLocation * location = [overlord userLocation];
    CLLocationCoordinate2D coord = [location locationCoordinate];
    CLLocation * userLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    CLLocationCoordinate2D pcoord = [[place location] locationCoordinate];
    CLLocation * placeLocation = [[CLLocation alloc]initWithLatitude:pcoord.latitude longitude:pcoord.longitude];
    double dist = [userLocation distanceFromLocation:placeLocation];
    return dist;
}

#pragma mark - Action Sheet Delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if([self distanceInMetersToPlace:self.mapViewController.selectedPlace] < 300){
            id<STOverlord> overlord = [STHiveCluster spawnOverlord];
            [overlord checkInPlace:self.mapViewController.selectedPlace completion:^(STUser *user, STPlace *place) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check in!" message:[NSString stringWithFormat:@"Check in feito em: %@", place.placeName] delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
                [alert show];
            } error:^(NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro!" message:@"Falha ao fazer check-in." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }];
        } else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro!" message:@"Você está muito longe desse lugar!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    }
}


#pragma mark - Delegate Notification
- (void) draggerCompletedCheckin {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Confirmar check-in?" delegate:self cancelButtonTitle:@"Não" destructiveButtonTitle:nil otherButtonTitles: @"Sim",nil];
    [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];

    [sheet showInView:self.view];
}
- (void) draggerSliderButtonPressed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(draggerViewControllerSliderButtonPressed:)]) {
        [self.delegate draggerViewControllerSliderButtonPressed:self];
    }
}
- (void) draggerWillShowCallout {
    if (self.delegate && [self.delegate respondsToSelector:@selector(draggerViewControllerWillShowCallout:)]) {
        [self.delegate draggerViewControllerWillShowCallout:self];
    }
}
- (void) draggerDidShowCallout {
    if (self.delegate && [self.delegate respondsToSelector:@selector(draggerViewControllerDidShowCallout:)]) {
        [self.delegate draggerViewControllerDidShowCallout:self];
    }
}
- (void) draggerWillHideCallout {
    if (self.delegate && [self.delegate respondsToSelector:@selector(draggerViewControllerWillHideCallout:)]) {
        [self.delegate draggerViewControllerWillHideCallout:self];
    }
}
- (void) draggerDidHideCallout {
    if (self.delegate && [self.delegate respondsToSelector:@selector(draggerViewControllerDidHideCallout:)]) {
        [self.delegate draggerViewControllerDidHideCallout:self];
    }
}
@end
