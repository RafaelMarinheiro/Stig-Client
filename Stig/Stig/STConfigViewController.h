//
//  STConfigViewController.h
//  Stig
//
//  Created by Lucas Tenório on 16/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STOverlord.h"
@interface STConfigViewController : UITableViewController
- (IBAction)networkSwitchChanged:(UISwitch *)sender;
- (IBAction)doneButtonPressed:(UIButton *)sender;

@end
