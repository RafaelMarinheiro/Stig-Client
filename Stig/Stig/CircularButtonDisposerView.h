//
//  CircularButtonDisposerView.h
//  PJPrototype
//
//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CircularButtonDisposerDelegate;

@interface CircularButtonDisposerView : UIView

@property (nonatomic, weak) id <CircularButtonDisposerDelegate> delegate;
@property (nonatomic, strong) NSNumber *disposeRadius; 
@property (nonatomic, strong) NSNumber *disposeAngle;
@property (nonatomic) CGPoint disposeCenter;
@property (nonatomic) float bounceRadiusDelta;
@property (nonatomic) NSUInteger numberOfButtons;
@property (nonatomic, strong) UIButton *mainButton;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic) BOOL shouldRotateMainButton;
@property (nonatomic, readonly, getter = isDisposing) BOOL disposing;
@property (nonatomic, readonly, getter = isAnimating) BOOL animating;
@property (nonatomic) BOOL disposeToTheRight;
@property (nonatomic) BOOL disposeToTheBottom;
@property (nonatomic) BOOL collapsesAfterButtonPress;

-(void) toggleDispose;

@end


@protocol CircularButtonDisposerDelegate <NSObject>
@optional
- (void) circularButtonDisposerView:(CircularButtonDisposerView *) disposer buttonPressed:(NSUInteger) buttonTag;
- (void) circularButtonDisposerViewWillDispose:(CircularButtonDisposerView *) disposer;
- (void) circularButtonDisposerViewDidDispose:(CircularButtonDisposerView *) disposer;
- (void) circularButtonDisposerViewWillHide:(CircularButtonDisposerView *) disposer;
- (void) circularButtonDisposerViewDidHide:(CircularButtonDisposerView *) disposer;
@end