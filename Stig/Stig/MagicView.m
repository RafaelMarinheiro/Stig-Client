//
//  MagicView.m
//  PJPrototype
//
//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "MagicView.h"

@implementation MagicView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self config];
    }
    return self;
}
- (void) layoutSubviews
{
	[renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}
- (void) config {
    self.backgroundColor = [UIColor clearColor];
    //mylayer = (CAEAGLLayer*)self.layer;

    renderer = [[MapOverlayRenderer alloc] init];
    [renderer setupTest];
    [self startRender];
    
}
- (void) startRender {
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0)) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
}
- (void) drawView:(id)sender
{
    [renderer render];
    
}

+(Class)layerClass {
    return [CAEAGLLayer class];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
