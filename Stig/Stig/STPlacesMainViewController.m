//
//  STPlacesViewController.m
//  PJPrototype
//
//  Created by Lucas Tenório on 22/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STPlacesMainViewController.h"
#import "STBoardViewController.h"
#import "STMapOverlayView.h"
#import <QuartzCore/QuartzCore.h>

@interface STPlacesMainViewController ()
    
@end



@implementation STPlacesMainViewController {
    STPlace *_selectedPlace;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    _showingMap = YES;
    _showingDropper = NO;
    self.filterButtonDisposer.delegate = self;
    self.optionsButtonDisposer.delegate = self;
    self.optionsButtonDisposer.disposeToTheRight = NO;
    self.optionsButtonDisposer.shouldRotateMainButton = YES;
    if (!self.places) {
        id<STOverlord> overlord = [STHiveCluster spawnOverlord];
        [overlord getPlacesWithSearchTerm:@"" pageNumber:0 completion:^(NSArray *places, NSUInteger pageNumber){
            self.places = places;
        }error:^(NSError *error) {
            NSLog(@"ERROR LOADING PLACES DATA !");
        }];
    }
    
    UIButton *filterMainButton = self.filterButtonDisposer.mainButton;
    NSArray *filterButtons = self.filterButtonDisposer.buttons;
    [filterMainButton setImage:[UIImage imageNamed:@"filter_yellow_50"] forState:UIControlStateNormal];
    [filterButtons[0] setImage:[UIImage imageNamed:@"Intercarlation.png"] forState:UIControlStateNormal];
    [filterButtons[1] setImage:[UIImage imageNamed:@"filter-buzz-44"] forState:UIControlStateNormal];
    [filterButtons[2] setImage:[UIImage imageNamed:@"filter-social-44"] forState:UIControlStateNormal];

    [self.suggestionButton addTarget:self action:@selector(suggestSomething:) forControlEvents:UIControlEventTouchUpInside];
}
- (void) viewWillAppear:(BOOL)animated {
//    self.searchBar.backgroundImage = [UIImage imageNamed:@"barra_topo_stig_name.png"];
//    self.searchBar.backgroundColor = [UIColor clearColor];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Suggestion Button

- (void) suggestSomething: (UIButton *) button{
    double k = -1;
    _selectedPlace = nil;
    
    for(int i = 0; i < [self.places count]; i++){
        STPlace * place = [self.places objectAtIndex:i];
        if([place.ranking.buzz floatValue] + [place.ranking.social floatValue] > k){
            k = [place.ranking.buzz floatValue] + [place.ranking.social floatValue];
            _selectedPlace = place;
        }
    }

    [self.draggerViewController.mapViewController selectPlace:_selectedPlace];
    
    
    [self.dropperLabel setText:_selectedPlace.placeName];
    [self showDropper];
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
#pragma mark - DropperView Delegate Methods
- (void) dragStarted {
    [self collapseDisposers];
}
- (void) dragCancelled {

}

- (void) dragCompleted {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Checkin!" message:[NSString stringWithFormat:@"Checkin at: %@", _selectedPlace.placeName] delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
    [alert show];
}
- (void) dragMoveWithPercentage:(NSNumber *)percentage {
    
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Dragger Segue"]) {
        self.draggerViewController = segue.destinationViewController;
        self.draggerViewController.delegate = self;
    }else if ([segue.identifier isEqualToString:@"List Segue"]){
        self.listViewController= segue.destinationViewController;
    }
}
#pragma mark - Circular Disposer Delegate Methods
- (void) circularButtonDisposerViewWillHide:(CircularButtonDisposerView *)disposer {
    [self collapseDisposers];
}
- (void) circularButtonDisposerView:(CircularButtonDisposerView *)disposer buttonPressed:(NSUInteger)buttonTag {
    if (disposer == self.filterButtonDisposer) {
        [self filterPressed:buttonTag];
    } else {
        [self optionsPressed:buttonTag];
    }
}

- (void) circularButtonDisposerViewWillDispose:(CircularButtonDisposerView *)disposer {
    if (disposer == self.filterButtonDisposer) {
        [self filterDisposed];
    }else {
        [self optionsDisposed];
    }
}
#pragma mark - Disposer Buttons Pressed
- (void) optionsPressed:(NSUInteger) optionNumber {
    
}
- (void) filterPressed:(NSUInteger) filterNumber {
    STRankingCriteria crit;
    if(filterNumber == 0){
        crit = ST_OVERALL;
    } else if(filterNumber == 1){
        crit = ST_BUZZ;
    } else{
        crit = ST_SOCIAL;
    }
    [self.draggerViewController.mapViewController setRankingCriteria:crit];
    [self collapseDisposers];
}
#pragma mark - Disposer States
- (void) collapseDisposers {
    [self.suggestionButton setAlpha:1.0];
    [self.suggestionButton setUserInteractionEnabled:YES];
    if ([self.filterButtonDisposer isDisposing]) {
        [self.filterButtonDisposer toggleDispose];
    }
    [self.filterButtonDisposer setAlpha:1.0];
    [self.filterButtonDisposer setUserInteractionEnabled:YES];
    if ([self.optionsButtonDisposer isDisposing]) {
        [self.optionsButtonDisposer toggleDispose];
    }
    [self.optionsButtonDisposer setAlpha:1.0];
    [self.optionsButtonDisposer setUserInteractionEnabled:YES];
}
- (void) optionsDisposed {
    [self.suggestionButton setAlpha:0.2];
    [self.suggestionButton setUserInteractionEnabled:NO];
    if ([self.filterButtonDisposer isDisposing]) {
        [self.filterButtonDisposer toggleDispose];
    }
    [self.filterButtonDisposer setAlpha:0.2];
    [self.filterButtonDisposer setUserInteractionEnabled:NO];
    
}
- (void) filterDisposed {
    [self.suggestionButton setAlpha:0.3];
    [self.suggestionButton setUserInteractionEnabled:NO];
    if ([self.optionsButtonDisposer isDisposing]) {
        [self.optionsButtonDisposer toggleDispose];
    }
    [self.optionsButtonDisposer setAlpha:0.3];
    [self.optionsButtonDisposer setUserInteractionEnabled:NO];
}

#pragma mark - Dropper Movement

- (void) showDropper {
    if (!self.showingDropper) {
        [self.dropperView showBasicInformation:^(BOOL completed){
            _showingDropper = YES;
        }];
    }
}
-(void) hideDropper {
    if (self.showingDropper) {
        [self.dropperView hide: ^(BOOL completed){
            _showingDropper = NO;
        }];
    }
}
#pragma mark - Pushing View Controller
- (void) pushBoardViewControllerWithPlace:(STPlace *)place {
    STBoardViewController *viewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"STBoardViewControllerID"];
    viewController.place = place;
    [self.navigationController pushViewController:viewController animated:YES];
}
- (IBAction)stickerButtonPressed:(UIButton *)sender {
    [self pushBoardViewControllerWithPlace:_selectedPlace];
}
- (IBAction)switcherButtonPressed:(UIButton *)sender {
    if (self.showingMap) {
        [self hideDropper];
        [sender setImage:[UIImage imageNamed:@"icon_map.png"] forState:UIControlStateNormal];
        self.suggestionButton.hidden = YES;
        self.filterButtonDisposer.hidden = YES;
        [UIView transitionFromView:self.mapViewContainer toView:self.listViewContainer duration:0.40 options:UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL completed) {
            _showingMap = NO;
        }];
    }else{
        self.suggestionButton.hidden = NO;
        self.filterButtonDisposer.hidden = NO;
        [sender setImage:[UIImage imageNamed:@"icon_list.png"] forState:UIControlStateNormal];
        [UIView transitionFromView:self.listViewContainer toView:self.mapViewContainer duration:0.40 options:UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL completed) {
            _showingMap = YES;
        }];
    }
}

#pragma mark - Dragger View Controller Delegate
- (void) draggerViewControllerWillShowCallout:(STDraggerViewController *)draggerViewController {
    NSLog(@"will show callout");
}
- (void) draggerViewControllerDidShowCallout:(STDraggerViewController *)draggerViewController {
    NSLog(@"did show callout");
}
- (void) draggerViewControllerWillHideCallout:(STDraggerViewController *)draggerViewController {
    NSLog(@"will hide callout");
}
- (void) draggerViewControllerDidHideCallout:(STDraggerViewController *)draggerViewController {
    NSLog(@"did hide callout");
}
@end
