//
//  STComposePostViewController.h
//  Stig
//
//  Created by Lucas Tenório on 12/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STStickerComposerView.h"

@interface STComposePostViewController : UIViewController <STStickerComposerDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet STStickerComposerView *stickerComposerView;
@property (nonatomic) STOverlordToken overlordToken;
@property (nonatomic, strong) STPlace *place;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *customNavigationItem;

@property (nonatomic, strong) void (^completionHandler)(BOOL completed);

- (IBAction)closeButtonPressed:(id)sender;
- (IBAction)postButtonPressed:(id)sender;
@end
