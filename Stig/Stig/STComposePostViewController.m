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

static NSUInteger _MAX_CHAR_COUNT = 200;

@implementation STComposePostViewController {
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.textView becomeFirstResponder];
    self.textView.delegate = self;
    self.postButton.enabled = NO;
    NSLog(@"TEste : %@ %@", self.postButton, self.cancelButton);
    STUser *user = [STHiveCluster spawnOverlord].user;
    [self.userImageView setImageWithURL:[NSURL URLWithString:user.userImageURL]];
    [self.userImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.userImageView.layer setCornerRadius:5.0];
    [self.userImageView.layer setMasksToBounds:YES];
    [self.charsLabel setText:[NSString stringWithFormat:@"%d", _MAX_CHAR_COUNT]];

//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//    label.backgroundColor = [UIColor clearColor];
//    label.font = [UIFont fontWithName:@"Futura" size:20.0];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = @"New Comment";
//    label.textColor = [UIColor whiteColor];
//    [label sizeToFit];
//    self.customNavigationItem.titleView = label;
    self.stickerComposerView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    self.bottomConstraint.constant = kbSize.height;
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.bottomConstraint.constant = 0.0;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) enablePost {
    
}
- (void) disablePost {

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
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([[textView text] length] - range.length + text.length > _MAX_CHAR_COUNT) {
        return NO;
    }
    return YES;
}
- (void) textViewDidChange:(UITextView *)textView {
    NSInteger count = _MAX_CHAR_COUNT - [textView.text length];
    if (count > 0 && count <=200) {
        self.postButton.enabled = YES;
    }else {
        self.postButton.enabled = NO;
    }
    [self.charsLabel setText:[NSString stringWithFormat:@"%d",count]];
    [self.stickerComposerView collapseStickers];
}
@end
