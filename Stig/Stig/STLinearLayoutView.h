//
//  STLinearLayoutView.h
//  Stig
//
//  Created by Lucas Tenório on 31/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLinearLayoutView : UIView

@property (nonatomic, readonly) CGSize viewSize;
@property (nonatomic, readonly) CGFloat viewSeparatorDistance;
@property (nonatomic, readonly) CGFloat edgeSeparatorDistance;
@property (nonatomic, readonly) NSArray *views;

- (id) initWithViews:(NSArray *) views
            viewSize:(CGSize) viewSize
       viewSeparator:(CGFloat) viewSeparator
    andEdgeSeparator:(CGFloat ) edgeSeparator;
@end
