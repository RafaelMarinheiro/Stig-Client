//
//  STLogInViewController.h
//  Stig
//
//  Created by Lucas Tenório on 24/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLogInViewController : UIViewController
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)logInButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *barsImageView;
@property (weak, nonatomic) IBOutlet UILabel *connectWithLabel;

@end
