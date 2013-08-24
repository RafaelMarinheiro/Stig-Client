//
//  STLogInViewController.m
//  Stig
//
//  Created by Lucas Tenório on 24/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STLogInViewController.h"

@interface STLogInViewController ()

@end

@implementation STLogInViewController

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

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logInButtonPressed:(id)sender {
    NSLog(@"LOGARRRRRRRRR");
}
@end
