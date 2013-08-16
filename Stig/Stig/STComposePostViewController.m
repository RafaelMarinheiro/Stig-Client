//
//  STComposePostViewController.m
//  Stig
//
//  Created by Lucas Tenório on 12/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STComposePostViewController.h"

#import <QuartzCore/QuartzCore.h>
@interface STComposePostViewController ()

@end

@implementation STComposePostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        // Custom initialization
//        [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
//        [self setModalPresentationStyle:UIModalPresentationCurrentContext];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.textView becomeFirstResponder];
    UIImage *back = [[UIImage imageNamed:@"bordertest.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    //NSLog(@"Image:%@", back);
//    [self.postButton setBackgroundImage:back forState:UIControlStateNormal];
//    [self.cancelButton setBackgroundImage:back forState:UIControlStateNormal];
//    [self.postButton sizeToFit];
//    [self.cancelButton sizeToFit];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
