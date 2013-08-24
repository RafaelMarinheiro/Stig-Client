//
//  STProfileViewController.m
//  Stig
//
//  Created by Lucas Tenório on 21/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STProfileViewController.h"
#import "STOverlord.h"
#import "UIImageView+AFNetworking.h"

@interface STProfileViewController ()

@end

@implementation STProfileViewController

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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Futura" size:20.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Profile";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.customNavigationItem.titleView = label;
    STUser *user = [STHiveCluster spawnOverlord].user;
    self.userLabel.text = user.userName;
    [self.userImage setImageWithURL:[NSURL URLWithString:user.userImageURL]];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
