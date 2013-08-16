//
//  STConfigViewController.m
//  Stig
//
//  Created by Lucas Tenório on 16/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STConfigViewController.h"

@interface STConfigViewController ()

@end

@implementation STConfigViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)networkSwitchChanged:(UISwitch *)sender {
    if (sender.on) {
        [STHiveCluster setDefaultOverlordType:STOverlordTypeNetworked];
    }else {
        [STHiveCluster setDefaultOverlordType:STOverlordTypeLocalJson];
    }
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
