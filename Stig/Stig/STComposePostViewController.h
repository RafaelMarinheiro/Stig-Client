//
//  STComposePostViewController.h
//  Stig
//
//  Created by Lucas Tenório on 12/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STComposePostViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)closeButtonPressed:(id)sender;
- (IBAction)postButtonPressed:(id)sender;

@end
