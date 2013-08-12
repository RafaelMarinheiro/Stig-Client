//
//  STSticker.m
//  Stig
//
//  Created by Lucas Tenório on 08/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STSticker.h"



@implementation STSticker
- (id) initWithType:(STStickerType)type andModificator:(STSTickerModifier)modifier {
    self = [super init];
    if (self) {
        _type = type;
        _modifier = modifier;
    }
    return self;
}
@end
