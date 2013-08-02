//
//  STLinearLayoutView.m
//  Stig
//
//  Created by Lucas Tenório on 31/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STLinearLayoutView.h"

@implementation STLinearLayoutView;
#pragma mark - Initialization

- (id) initWithViews:(NSArray *)views viewSize:(CGSize)viewSize viewSeparator:(CGFloat)viewSeparator andEdgeSeparator:(CGFloat)edgeSeparator {
    self = [super init];
    if (self) {
        _views = views;
        _viewSize = viewSize;
        _viewSeparatorDistance = viewSeparator;
        _edgeSeparatorDistance = edgeSeparator;
        [self config];
    }
    return self;
}
- (void) config {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    NSUInteger viewsCount = [self.views count];
    for (int i = 0; i < viewsCount; i++) {
        UIView *view = self.views[i];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        NSNumber *rightPadding =[NSNumber numberWithFloat:( self.edgeSeparatorDistance + i*self.viewSize.width + i*self.viewSeparatorDistance)];
        NSNumber *upperPadding = [NSNumber numberWithFloat:self.edgeSeparatorDistance];
        NSNumber *height =[NSNumber numberWithFloat:self.viewSize.height];
        NSNumber *width = [NSNumber numberWithFloat:self.viewSize.width];

        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-upperPadding-[view(height)]-upperPadding-|"
                              options:0
                              metrics:@{@"upperPadding":upperPadding,
                              @"height":height}
                              views:NSDictionaryOfVariableBindings(view)]];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-rightPadding-[view(width)]"
                              options:0
                              metrics:@{@"rightPadding":rightPadding,
                              @"width":width}
                              views:NSDictionaryOfVariableBindings(view)]];


    }
}
- (BOOL) translatesAutoresizingMaskIntoConstraints {
    return NO;
}

- (CGSize) intrinsicContentSize {
    NSUInteger viewCount = [self.views count];
    CGFloat width = 2*self.edgeSeparatorDistance + viewCount*self.viewSize.width;
    if (viewCount) {
        width+=(viewCount-1)*self.viewSeparatorDistance;
    }
    CGFloat height = 2*self.edgeSeparatorDistance + MIN(viewCount, 1) * self.viewSize.height;
    return CGSizeMake(width, height);
}

@end
