//
//  CircularButtonDisposerView.h
//  PJPrototype
//
//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircularButtonDisposerView : UIView

@property (nonatomic, strong) NSNumber *disposeRadius; 
@property (nonatomic, strong) NSNumber *disposeAngle; //Only supports pi/2 in this beta
@property (nonatomic, strong) NSArray *viewsToDispose; //Only supports 5 in this beta
@property (nonatomic, readonly) NSUInteger numberOfViewsToDispose;
@property (nonatomic, readonly, getter = isDisposing) BOOL disposing;
@end
