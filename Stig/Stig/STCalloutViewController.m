//
//  STCalloutViewController.m
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STCalloutViewController.h"
#import "STBoardViewController.h"



@implementation STCalloutViewController {
    STPlace *_selectedPlace;
    UIColor *_initialColor;
    UIColor *_finalColor;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    _initialColor = [UIColor colorWithRed:255/255.0 green:206/255.0 blue:59/255.0 alpha:0.0/255.0];
    _finalColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.checkinLabel.textColor = _initialColor;
	// Do any additional setup after loading the view.
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    STBoardViewController *vc = segue.destinationViewController;
    vc.place = _selectedPlace;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) changeForPercentage:(CGFloat)percentage {
    if (percentage>=0.0 && percentage <=1.0) {
        UIColor *color = [self colorInterpolatingColor:_initialColor toColor:_finalColor withPercentage:percentage];
        UIColor *ellipseColor = [self colorInterpolatingColor:[_initialColor colorWithAlphaComponent:1.0]  toColor:_finalColor withPercentage:percentage];
        self.checkinLabel.textColor = color;
        [self.animationView setPercentage:percentage];
        [self.animationView setEllipseColor:ellipseColor];
        [self.stickerSelector setAlpha:1.0-percentage];
        [self.placeNameLabel  setAlpha:1.0-percentage];
    }
}

- (IBAction)driveButtonPressed:(id)sender {

    NSString* urlStr;
    NSString* saddr = @"Current+Location";
    NSString *daddr = [NSString stringWithFormat:@"%f,%f", _selectedPlace.location.locationCoordinate.latitude,_selectedPlace.location.locationCoordinate.longitude];
    CLLocationCoordinate2D currentLocation = [STHiveCluster spawnOverlord].userLocation.locationCoordinate;
    if ((currentLocation.latitude != kCLLocationCoordinate2DInvalid.latitude) && (currentLocation.longitude != kCLLocationCoordinate2DInvalid.longitude)) {
        //Valid location.
        saddr = [NSString stringWithFormat:@"%f,%f", currentLocation.latitude,currentLocation.longitude];
        
        urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%@&daddr=%@", saddr, daddr];
        //urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%@", daddr];
    } else {
        //Invalid location. Location Service disabled.
        urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%@", daddr];
    }

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}
- (void) showCalloutForPlace:(STPlace *) place {
    _selectedPlace = place;
    [self.placeNameLabel setText:place.placeName];
    [self.stickerSelector setStickers:place.stickers];
}
- (UIColor *) colorInterpolatingColor:(UIColor *) initialColor toColor:(UIColor *) finalColor withPercentage:(CGFloat) percentage {
    CGFloat initialRed, initialGreen, initialBlue, initialAlpha;
    [initialColor getRed:&initialRed green:&initialGreen blue:&initialBlue alpha:&initialAlpha];
    CGFloat finalRed, finalGreen, finalBlue, finalAlpha;
    [finalColor getRed:&finalRed green:&finalGreen blue:&finalBlue alpha:&finalAlpha];

    CGFloat redDelta = (finalRed - initialRed) * percentage;
    CGFloat greenDelta = (finalGreen - initialGreen) * percentage;
    CGFloat blueDelta = (finalBlue - initialBlue) * percentage;
    CGFloat alphaDelta = (finalAlpha - initialAlpha) * percentage;

    return [UIColor colorWithRed:initialRed+redDelta green:initialGreen+greenDelta blue:initialBlue + blueDelta alpha:initialAlpha+alphaDelta];
}
@end
