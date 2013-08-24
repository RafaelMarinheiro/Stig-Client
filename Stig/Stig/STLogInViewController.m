//
//  STLogInViewController.m
//  Stig
//
//  Created by Lucas Tenório on 24/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STLogInViewController.h"
#import <FacebookSDK/FacebookSDK.h>
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

- (IBAction)logInButtonPressed:(id)sender {
    [FBSession.activeSession openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                            completionHandler:^(FBSession *session,
                                                FBSessionState status,
                                                NSError *error) {
                                if ([FBSession.activeSession isOpen]) {
                                    [[FBRequest requestForMe] startWithCompletionHandler:
                                     ^(FBRequestConnection *connection,
                                       NSDictionary<FBGraphUser> *user,
                                       NSError *error) {
                                         if(!error){
                                             NSNumberFormatter * f = [[NSNumberFormatter alloc]init];
                                             NSNumber * uid = [f numberFromString:[user id]];

                                             id<STOverlord> overlord = [STHiveCluster spawnOverlord];
                                             [overlord authenticateUserWithId: uid withPassword:[[FBSession.activeSession accessTokenData] accessToken] completion:^(STUser *user) {
                                                 
                                             } error:^(NSError *error) {
                                                 <#code#>
                                             }]
                                             }
                                     }];
                                }
                            }];
}
@end
