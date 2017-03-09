//
//  STCalloutViewController.m
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STCalloutViewController.h"
#import "STBoardViewController.h"
#import "UIColor+Stig.h"


@implementation STCalloutViewController {
    STPlace *_selectedPlace;
    UIColor *_initialColor;
    UIColor *_finalColor;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    _initialColor = [[UIColor stigYellow] colorWithAlphaComponent:0.0];
    _finalColor = [UIColor stigWhite];
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
        UIColor *color = [UIColor colorInterpolatingColor:_initialColor toColor:_finalColor withPercentage:percentage];
        UIColor *ellipseColor = [UIColor colorInterpolatingColor:[_initialColor colorWithAlphaComponent:1.0]  toColor:_finalColor withPercentage:percentage];
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
@end
