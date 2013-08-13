//
//  STCalloutViewController.h
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPlace.h"
#import "STCheckInAnimationView.h"
#import "STStickerPickerView.h"

@interface STCalloutViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
- (void) showCalloutForPlace:(STPlace *) place;
@property (weak, nonatomic) IBOutlet UILabel *checkinLabel;
@property (weak, nonatomic) IBOutlet STStickerPickerView *stickerSelector;
@property (weak, nonatomic) IBOutlet STCheckInAnimationView *animationView;
- (void) changeForPercentage:(CGFloat) percentage;

@end
