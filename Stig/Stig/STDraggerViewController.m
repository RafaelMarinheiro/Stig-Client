//
//  STDraggerViewController.m
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STDraggerViewController.h"

static CGFloat const STDraggerShowingHeight = 100.0;
static CGFloat const STDraggerBounceDelta = 5.0;

static CGFloat const STDraggerTotalHeight = 501.0;
@interface STDraggerViewController ()

@end

@implementation STDraggerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _state = STDraggerStateHidden;
    self.dragGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                  initWithTarget:self action:@selector(respondToPanGesture:)];

    NSLog(@"dragger constraint : %@", self.verticalSpaceConstraint);
    [self.draggedView addGestureRecognizer:self.dragGestureRecognizer];
	// Do any additional setup after loading the view.
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
        self.mapViewController.places = _places;
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

    NSLog(@"called");
    CGPoint translation = [recognizer translationInView:self.view];
    if([recognizer state] == UIGestureRecognizerStateBegan){
        _state = STDraggerStateDragging;
    }
    if(_state == STDraggerStateDragging){
        if(translation.y < 0) return;

        self.verticalSpaceConstraint.constant = -(translation.y + STDraggerShowingHeight);
        [self.view layoutIfNeeded];

        if(translation.y >= 328){
            [self moveDraggerToShowingPositionWithCompletion:^(BOOL completed){
                //NOTIFY DELEGATE
            }];
            

        } else if (([recognizer state] == UIGestureRecognizerStateEnded) || ([recognizer state] == UIGestureRecognizerStateCancelled)) {
            [self moveDraggerToShowingPositionWithCompletion:^(BOOL completed){
                //NOTIFY DELEGATE SHIT WENT DOWN
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
        [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.verticalSpaceConstraint.constant = -(STDraggerShowingHeight + STDraggerBounceDelta);
            [self.view layoutIfNeeded];
        }completion:^(BOOL completed){
            self.verticalSpaceConstraint.constant = -STDraggerShowingHeight;
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
- (void) hideDraggerWithCompletion:(void (^)(BOOL completed) )completion {
    if (self.state == STDraggerStateShowing) {
        _state = STDraggerStateAnimating;

        [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.verticalSpaceConstraint.constant = 0.0;
            [self.view layoutIfNeeded];
        }completion:^(BOOL completed){
            _state = STDraggerStateHidden;
            if (completion) {
                completion(completed);
            }
        }];
    }
}

- (void) moveDraggerToShowingPositionWithCompletion:( void (^)(BOOL completed)) completion {
    if (self.state == STDraggerStateDragging) {
        _state = STDraggerStateAnimating;

        [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.verticalSpaceConstraint.constant = -(STDraggerShowingHeight - STDraggerBounceDelta);
            [self.view layoutIfNeeded];
        }completion:^(BOOL completed){
            self.verticalSpaceConstraint.constant = -STDraggerShowingHeight;
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

@end
