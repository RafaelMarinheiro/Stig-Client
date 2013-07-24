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
@interface STBoardViewController : UITableViewController

@property (nonatomic, strong) STPlace *place;
@property (nonatomic, readonly) BOOL loadedPlace;
@property (nonatomic, readonly) BOOL loadedComments;
@property (nonatomic, strong) UIFont *commentFont;
@property (nonatomic, strong) UIFont *userNameFont;
@property (nonatomic, readonly) NSMutableDictionary *comments;
@property (nonatomic, readonly) NSMutableDictionary *commentsUsers;

@end
