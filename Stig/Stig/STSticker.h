//
//  STSticker.h
//  Stig
//
//  Created by Lucas Tenório on 08/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    STStickerTypeMoney,
    STStickerTypeFood,
    STStickerTypeQueue,
    STStickerTypeMusic,
    STStickerTypeAccessibility,
    STStickerTypePeople
}STStickerType;
typedef enum {
    STStickerModifierBad,
    STSTickerModifierNeutral,
    STSTickerModifierGood
}STSTickerModifier;
@interface STSticker : NSObject
@property (nonatomic, readonly) STStickerType type;
@property (nonatomic, readonly) STSTickerModifier modifier;
- (id) initWithType:(STStickerType) type andModificator:(STSTickerModifier) modifier;
@end
