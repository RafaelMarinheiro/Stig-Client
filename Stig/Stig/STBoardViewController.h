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
@interface STBoardViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) STPlace *place;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) BOOL loadedPlace;
@property (nonatomic, readonly) BOOL loadedComments;
@property (nonatomic, strong) UIFont *commentFont;
@property (nonatomic, strong) UIFont *userNameFont;
@property (nonatomic, readonly) NSMutableDictionary *comments;
@property (nonatomic, readonly) NSMutableDictionary *commentsUsers;
@property (weak, nonatomic) IBOutlet UIView *stickersView;
@property (weak, nonatomic) IBOutlet UILabel *topBatTitle;
@property (weak, nonatomic) IBOutlet UINavigationItem *customNavigationItem;
- (IBAction)stickerButtonPressed:(UIButton *)sender;
- (IBAction)backButtonPressed:(UIButton *)sender;
- (IBAction)postButtonPressed:(id)sender;


@end
