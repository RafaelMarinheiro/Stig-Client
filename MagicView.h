//
//  MagicView.h
//  PJPrototype
//
//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "QuartzCore/CAEAGLLayer.h"
//#import "MapOverlayRenderer.h"

@interface MagicView : UIView {
    CAEAGLLayer *mylayer;
    //MapOverlayRenderer *renderer;
    NSTimer *animationTimer;
}

@end
