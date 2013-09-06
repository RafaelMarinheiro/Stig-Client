//
//  STSwipeView.h
//  Stig
//
//  Created by Lucas Tenório on 28/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol STSwipeDelegate;

@interface STSwipeView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <STSwipeDelegate> delegate;
@property (nonatomic, strong, readonly) UIView *mainSwipeView;
@property (nonatomic, strong, readonly) UIView *leftSwipeView;
@property (nonatomic, strong, readonly) UIView *rightSwipeView;

@end


@protocol STSwipeDelegate <NSObject>

- (void) swipeViewDidSwipeLeft:(STSwipeView *) swipeView;
- (void) swipeViewDidSwipeRight:(STSwipeView *) swipeView;

@end