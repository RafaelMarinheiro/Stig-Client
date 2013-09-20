//
//  STLogInViewController.m
//  Stig
//
//  Created by Lucas Tenório on 24/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STLogInViewController.h"
#import "STOverlord.h"
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
- (void) changeToInteraction {
    [UIView animateWithDuration:0.25 animations:^{
        self.loginButton.alpha = 1.0;
        self.activityIndicator.alpha = 0.0;
        self.connectWithLabel.alpha = 1.0;
        self.barsImageView.alpha = 1.0;
    }];
}
-(void) changeToLoading {
    [UIView animateWithDuration:0.25 animations:^{
        self.loginButton.alpha = 0.0;
        self.activityIndicator.alpha = 1.0;
        self.connectWithLabel.alpha = 0.0;
        self.barsImageView.alpha = 0.0;
    }];
}
- (IBAction)logInButtonPressed:(id)sender {
    [self.activityIndicator startAnimating];
    [self changeToLoading];
    id<STOverlord> overlord = [STHiveCluster spawnOverlord];
    [overlord authenticateUserOpeningUI: YES completion:^(STUser *user) {
        [self.activityIndicator stopAnimating];
        [self dismissViewControllerAnimated:YES completion:nil];
    } error:^(NSError *error) {
        [overlord signInUserWithId:nil withPassword:nil completion:^(STUser *user) {
            [self.activityIndicator stopAnimating];
            [self dismissViewControllerAnimated:YES completion:nil];
        } error:^(NSError *error) {
            NSLog(@"ERROR LOGIN : %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro!" message:@"Erro ao fazer login" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            [self changeToInteraction];
        }];
    }];
}
@end
