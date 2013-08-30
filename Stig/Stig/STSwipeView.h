//
//  STSwipeView.h
//  Stig
//
//  Created by Lucas Tenório on 28/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STSwipeView : UIView<UIGestureRecognizerDelegate>
@property (nonatomic, strong, readonly) UIView *mainSwipeView;
@property (nonatomic, strong, readonly) UIView *leftSwipeView;
@property (nonatomic, strong, readonly) UIView *rightSwipeView;

@end
