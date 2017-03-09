//
//  STBoardViewController.h
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPlace.h"
#import "STOverlord.h"
#import "UIImageView+AFNetworking.h"
#import "STBoardCommentView.h"
#import "STStickerPickerView.h"
@interface STBoardViewController : UITableViewController <UITextFieldDelegate,STStickerPickerViewDelegate, STSwipeDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) STPlace *place;
@property (weak, nonatomic) IBOutlet UIView *stickersView;
@property (weak, nonatomic) IBOutlet UILabel *topBatTitle;
@property (weak, nonatomic) IBOutlet UINavigationItem *customNavigationItem;
@property (nonatomic, strong) NSArray *selectedStickers;
- (IBAction)postButtonPressed:(id)sender;
- (IBAction)directionsButtonPressed:(id)sender;
@end
