//
//  STSwipeView.h
//  Stig
//
//  Created by Lucas Tenório on 28/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    STSwipeViewSelectionStatusNone,
    STSwipeViewSelectionStatusLeft,
    STSwipeViewSelectionStatusRight
} STSwipeViewSelectionStatus;

@protocol STSwipeDelegate;

@interface STSwipeView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <STSwipeDelegate> delegate;
@property (nonatomic, strong, readonly) UIView *mainSwipeView;
@property (nonatomic, strong, readonly) UIView *leftSwipeView;
@property (nonatomic, strong, readonly) UIView *rightSwipeView;
@property (nonatomic, strong) UIView *leftIndicatorView;
@property (nonatomic, strong) UIView *rightIndicatorView;
@property (nonatomic) BOOL swipeEnabled;
@property (nonatomic) STSwipeViewSelectionStatus selectionStatus;
- (void) prepareForReuse;
@end


@protocol STSwipeDelegate <NSObject>
@optional
- (BOOL) swipeViewShouldSwipe:(STSwipeView *) swipeView;
- (void) swipeViewDidSwipeLeft:(STSwipeView *) swipeView;
- (void) swipeViewDidSwipeRight:(STSwipeView *) swipeView;

@end