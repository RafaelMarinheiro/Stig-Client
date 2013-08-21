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
    [self.userImageView.layer setCornerRadius:5.0];
    [self.userImageView.layer setMasksToBounds:YES];


    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Futura" size:20.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"New Comment";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.customNavigationItem.titleView = label;
    self.stickerComposerView.delegate = self;
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
- (void) stickerComposerWillDisposeStickers:(STStickerComposerView *)composer {
    [UIView animateWithDuration:0.2 animations:^{
        self.textView.alpha = 0.3;
    }];
}
- (void) stickerComposerWillHideStickers:(STStickerComposerView *)composer {
    [UIView animateWithDuration:0.2 animations:^{
        self.textView.alpha = 1.0;
    }];
}
@end
