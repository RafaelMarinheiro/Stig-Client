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
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
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
- (void) showCalloutForPlace:(STPlace *) place {
    _selectedPlace = place;
    [self.placeNameLabel setText:place.placeName];
}
@end
