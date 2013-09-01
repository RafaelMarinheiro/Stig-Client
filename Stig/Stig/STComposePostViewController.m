//
//  STComposePostViewController.m
//  Stig
//
//  Created by Lucas Tenório on 12/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STComposePostViewController.h"
#import "UIImageView+AFNetworking.h"

#import <QuartzCore/QuartzCore.h>
@interface STComposePostViewController ()

@end

@implementation STComposePostViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.textView becomeFirstResponder];
    self.textView.delegate = self;
    
    STUser *user = [STHiveCluster spawnOverlord].user;
    [self.userImageView setImageWithURL:[NSURL URLWithString:user.userImageURL]];
    [self.userImageView setContentMode:UIViewContentModeScaleAspectFill];
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
    id<STOverlord> overlord = [STHiveCluster spawnOverlord];
    [overlord postCommentWithText:self.textView.text andStickers:self.stickerComposerView.selectedStickers toPlaceWithId: self.place.placeId usingToken:self.overlordToken completion:^(STBoardComment *comment) {
        if (self.completionHandler) {
            self.completionHandler(YES);
        }
    } error:^(NSError *error) {
        if (self.completionHandler) {
            self.completionHandler(NO);
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark Sticker Composer Methods
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
#pragma mark Text View Methods
- (void) textViewDidChange:(UITextView *)textView {
    [self.stickerComposerView collapseStickers];
}
@end
