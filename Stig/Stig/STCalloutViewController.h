//
//  STCalloutViewController.h
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPlace.h"

@interface STCalloutViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
- (void) showCalloutForPlace:(STPlace *) place;

@end
