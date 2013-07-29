//
//  STPlacesViewController.m
//  PJPrototype
//
//  Created by Lucas Tenório on 22/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STPlacesViewController.h"
#import "STBoardViewController.h"
#import "STMapOverlayView.h"

@interface STPlacesViewController ()
    
@end



@implementation STPlacesViewController {
    STPlace *_selectedPlace;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    _showingMap = YES;
    _showingDropper = NO;
    self.dropperView.delegate = self;
    self.filterButtonDisposer.delegate = self;
    self.optionsButtonDisposer.delegate = self;
    self.optionsButtonDisposer.disposeToTheRight = NO;
    self.optionsButtonDisposer.shouldRotateMainButton = YES;
    if (!self.places) {
        STOverlord *overlord = [STOverlord sharedInstance];
        [overlord getPlacesWithSearchTerm:@"" pageNumber:0 completion:^(NSArray *places, NSUInteger pageNumber){
            self.places = places;
            [self.mapView setDelegate:self];
            [self.mapView addAnnotations:self.places];
            [self.mapView addOverlays:self.places];
            [self.mapView setRegion:[self regionFromAnnotations:self.places]];
            [self sortPlaces];
            STPlace *lastPlace = [self.places lastObject];
            //[self.tableView setBackgroundColor:[UIColor blackColor]];
            [self.tableView reloadData];
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_selectedPlace.coordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    
    [self.dropperLabel setText:_selectedPlace.placeName];
    [self showDropper];
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
    if([STMapOverlayView criteria] != crit){
        [STMapOverlayView setCriteria:crit];
        for (id st in [self.mapView overlays]) {
            if([st isKindOfClass:[STPlace class]]){
                id view = [self.mapView viewForOverlay:st];
                [view setNeedsDisplay];
            }

        }
    }
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

#pragma mark - MapView Delegate
- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [self.mapView setCenterCoordinate:[view.annotation coordinate] animated:YES];
    view.selected = NO;
    STPlace *place = (STPlace *)view.annotation;
    _selectedPlace = place;
    [self.dropperLabel setText:place.placeName];
    [self showDropper];
    [self collapseDisposers];
}
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    NSString * identifier = @"Pin";
//    MKAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//
//    if (!pin){
//        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
//        ((MKPinAnnotationView *)pin).pinColor = MKPinAnnotationColorPurple;
//        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    }
//    return pin;
    NSString * identifier = @"StigPin";
    MKAnnotationView *pin = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if(!pin){
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        //pin.image = [UIImage imageNamed:@"pino_40"];
        [((MKPinAnnotationView *)pin) setPinColor:MKPinAnnotationColorPurple];
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return pin;
}
- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    STPlace *place = (STPlace *) view.annotation;
    [self pushBoardViewControllerWithPlace:place];
}
- (MKCoordinateRegion) regionFromAnnotations:(NSArray *) annotations{
    id <MKAnnotation> first = annotations[0];
    CLLocationDegrees maxLongitude = first.coordinate.longitude;
    CLLocationDegrees minLogitude = first.coordinate.longitude;
    CLLocationDegrees maxLatitude = first.coordinate.latitude;
    CLLocationDegrees minLatitude = first.coordinate.latitude;


    for (id <MKAnnotation> annotation in annotations) {
        if (annotation.coordinate.latitude < minLatitude) {
            minLatitude = annotation.coordinate.latitude;
        }

        if (annotation.coordinate.latitude > maxLatitude) {
            maxLatitude = annotation.coordinate.latitude;
        }

        if (annotation.coordinate.longitude < minLogitude) {
            minLogitude = annotation.coordinate.longitude;
        }
        if (annotation.coordinate.longitude > maxLongitude) {
            maxLongitude = annotation.coordinate.longitude;
        }
    }
    CLLocationDegrees deltaLatitude = maxLatitude - minLatitude;

    CLLocationDegrees deltaLongitude = maxLongitude - minLogitude;
    CLLocationDegrees latitude = deltaLatitude/2.0  + minLatitude;
    CLLocationDegrees longitude = deltaLongitude/2.0 + minLogitude;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateSpan s = MKCoordinateSpanMake(deltaLatitude + 0.02, deltaLongitude + 0.02);
    return MKCoordinateRegionMake(coordinate, s);
}
- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (!animated) {
        [self hideDropper];
        [self collapseDisposers];
    }
}

#pragma mark - MapOverlay Delegate Methods

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    if([overlay isKindOfClass: [STPlace class]]){
        return [[STMapOverlayView alloc] initWithOverlay:overlay];
    }
    return nil;
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
        [UIView transitionFromView:self.mapView toView:self.tableView duration:0.5 options:UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL completed) {
            _showingMap = NO;
        }];
    }else{
        self.suggestionButton.hidden = NO;
        self.filterButtonDisposer.hidden = NO;
        [sender setImage:[UIImage imageNamed:@"icon_list.png"] forState:UIControlStateNormal];
        [UIView transitionFromView:self.tableView toView:self.mapView duration:0.5 options:UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL completed) {
            _showingMap = YES;
        }];
    }
}

#pragma mark - Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.places) {
        return [self.places count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([indexPath row]==0) {
//        static NSString *CellIdentifier = @"STBoardHeaderIdentifier";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 100.0f)];
//
//        [imageView setImageWithURL:[NSURL URLWithString:self.place.imageURL] placeholderImage:[UIImage imageNamed:@"uk-board.jpg"]];
//        [imageView setContentMode:UIViewContentModeScaleAspectFill];
//        [imageView setClipsToBounds:YES];
//        [cell.contentView addSubview:imageView];
//        [cell.contentView sendSubviewToBack:imageView];
//        return cell;
//    }
//    static NSString *CellIdentifier = @"STBoardCommentIdentifier";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//
//    STBoardComment *comment = self.comments[indexPath];
//    STUser *user = self.commentsUsers[indexPath];
//
//    if (user&&comment) {
//        STBoardCommentView *commentView =(STBoardCommentView *) [cell.contentView viewWithTag:100];
//        commentView.commentFont = self.commentFont;
//        commentView.userNameFont = self.userNameFont;
//        [commentView populateCommentWithText:comment.commentText userName:user.userName userImageURL:user.userImageURL andTimestamp:comment.commentTimestamp];
//    } else {
//        [self requestDataForIndexPath:indexPath];
//
//        NSLog(@"User: %@, COmment %@", user, comment);
//    }
//    return cell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    STPlace *place = self.places[indexPath.row];
    [cell.contentView setBackgroundColor:[self colorForRanking:place.ranking]];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    [cell.textLabel setFont:[UIFont fontWithName:@"Futura" size:20.0]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setText:place.placeName];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    //[cell.detailTextLabel setText:place.placeDescription];
    return cell;
}
- (UIColor *) colorForRanking:(STRanking *) ranking {
    float max = [((STPlace *) self.places[0]).ranking.overall floatValue];

   // UIColor *baseColor = [UIColor colorWithRed:26.0/255.0 green:188.0/255.0 blue:156.0/255.0 alpha:1.0];
    UIColor *baseColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    CGFloat alpha = [ranking.overall floatValue]/max + 0.05;
    return [baseColor colorWithAlphaComponent:alpha];
}
- (void) sortPlaces {
    NSArray *sorted  = [self.places sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
        if ([a isKindOfClass:[STPlace class]] && [b isKindOfClass:[STPlace class]]){

            STPlace *first = a;
            STPlace *second = b;
            float left = [first.ranking.overall floatValue];
            float right = [second.ranking.overall floatValue];
            if (left < right) {
                return NSOrderedDescending;
            }else if (left == right){
                return NSOrderedSame;
            } else {
                return NSOrderedAscending;
            }
        } else {

        }
        return NSOrderedSame;
    }];
    self.places = sorted;
}
#pragma mark - Table View Delegate Methods
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STPlace *place = self.places[indexPath.row];
    [self pushBoardViewControllerWithPlace:place];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
