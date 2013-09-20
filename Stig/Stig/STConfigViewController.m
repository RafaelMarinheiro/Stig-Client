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
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableViewBackground.png"]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signOutButtonPressed:(id)sender {
    [[STHiveCluster spawnOverlord] signOutWithCompletion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout" message:@"Logout efetuado com sucesso!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
    } error:^(NSError *error) {
        NSLog(@"Falha ao tentar deslogar");
    }];
}

- (IBAction)contactButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"mailto:contact@stigapp.co"]];
}

- (IBAction)websiteButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.stigapp.co"]];
}
@end
