//
//  STSticker.m
//  Stig
//
//  Created by Lucas Tenório on 08/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STSticker.h"



@implementation STSticker
- (id) initWithType:(STStickerType)type andModifier:(STSTickerModifier)modifier {
    self = [super init];
    if (self) {
        _type = type;
        _modifier = modifier;
        _stickerId = @(type * 3 + modifier);
    }
    return self;
}
- (id) initWithId:(NSNumber *)stickerId {
    NSInteger type = [stickerId integerValue] / 3;
    NSInteger modifier = [stickerId integerValue] % 3;
    
    if (type >=0 && type <6) {
        if (modifier >= 0 && modifier<3) {
            return [[STSticker alloc] initWithType:type andModifier:modifier];
        }
    }
    return nil;
}
+ (STStickerType) typeForString:(NSString *) stringType{
    if ([stringType isEqualToString:@"accessibility"]) {
        return STStickerTypeAccessibility;
    } else if ([stringType isEqualToString:@"food"]) {
        return STStickerTypeFood;
    } else if ([stringType isEqualToString:@"money"]) {
        return STStickerTypeMoney;
    } else if ([stringType isEqualToString:@"music"]) {
        return STStickerTypeMusic;
    } else if ([stringType isEqualToString:@"people"]) {
        return STStickerTypePeople;
    } else if ([stringType isEqualToString:@"queue"]) {
        return STStickerTypeQueue;
    } else {
        return -1;
    }
}
+ (NSString *) stringForStickerType:(STStickerType) type {
    switch (type) {
        case STStickerTypeAccessibility:
            return @"accessibility";
        case STStickerTypeFood:
            return @"food";
        case STStickerTypeMoney:
            return @"money";
        case STStickerTypeMusic:
            return @"music";
        case STStickerTypePeople:
            return @"people";
        case STStickerTypeQueue:
            return @"queue";
    }
    return nil;
}
+ (NSString *) stringForStickerModifier:(STSTickerModifier) modifier {
    switch (modifier) {
        case STStickerModifierBad:
            return @"bad";
        case STSTickerModifierGood:
            return @"good";
        case STSTickerModifierNeutral:
            return @"neutral";
    }
    return nil;
}
- (NSString *) description {
    return [NSString stringWithFormat:@"[Sticker %@: %@ %@]", self.stickerId, [STSticker stringForStickerType:self.type],[STSticker stringForStickerModifier:self.modifier]];
}
- (UIImage *) stickerIconWithPlace:(NSString *) place {
    NSString *imageName = [NSString stringWithFormat:@"icon_sticker_%@_%@_%@",[STSticker stringForStickerType:self.type],[STSticker stringForStickerModifier:self.modifier],place];

    return [UIImage imageNamed:imageName];
    
}

- (NSUInteger)getServerCode{
    if(self.modifier == STSTickerModifierGood){
        return ((0b10) << (self.type*2));
    } else{
        return ((0b01) << (self.type*2));
    }
}

- (NSUInteger)getQueryServerCode{
    return (0b1 << self.type);
}

+ (NSUInteger) stickersServeCodeFromArray: (NSArray *) array{
    if(!array){
        return 0;
    }
    NSUInteger ret = 0;
    for(int i = 0; i < array.count; i++){
        ret = (ret | [array[i] getServerCode]);
    }
    return ret;
}

+ (NSUInteger) stickersServerQueryCodeFromArray:(NSArray *)array{
    if(!array){
        return 0;
    }
    NSUInteger ret = 0;
    for(int i = 0; i < array.count; i++){
        ret = (ret | [array[i] getQueryServerCode]);
    }
    return ret;
}

+ (NSArray *) stickersWithServerCode: (NSUInteger) code{
    NSMutableArray *stickers = [NSMutableArray arrayWithCapacity:6];

    for(int i = 0; i < 6; i++){
        STStickerType type = i;
        if((code&0b11) == 0b10){
            [stickers addObject:[[STSticker alloc] initWithType:type andModifier:STSTickerModifierGood]];
        } else if((code&0b11) == 0b01){
            [stickers addObject:[[STSticker alloc] initWithType:type andModifier:STStickerModifierBad]];
        }
        code = (code >> 2);
    }
    
    return stickers;
}
+ (STSticker *) relevantStickerFromStatusDictionary:(NSDictionary *) dictionary {
    if ([dictionary count] == 0) {
        return nil;
    }
    
    NSUInteger biggest = abs([dictionary[[[dictionary allKeys] lastObject]] integerValue]);
    
    NSString *mostRelevant;
    
    for (NSString *key in  [dictionary allKeys]) {
        NSNumber *value = dictionary[key];
        if (abs([value integerValue])>=biggest) {
            mostRelevant = key;
            biggest = abs([value integerValue]);
        }
    }
    
    NSNumber *mod = dictionary[mostRelevant];
    STStickerType type = [STSticker typeForString:mostRelevant];
    STSTickerModifier modifier;
    if ([mod integerValue] > 0) {
        modifier = STSTickerModifierGood;
    }else if ([mod integerValue] < 0) {
        modifier = STStickerModifierBad;
    }else {
        return nil;
    }
    STSticker *result = [[STSticker alloc] initWithType:type andModifier:modifier];
    return result;
}
+ (NSArray *) stickersWithStatusDictionary:(NSDictionary *) dictionary {
    
    NSMutableArray *stickers = [NSMutableArray arrayWithCapacity:6];
    for (int i = 0; i < 6; i++) {

        NSString *type = [STSticker stringForStickerType:i];
        NSNumber * mod = dictionary[type];
        if (mod) {
            NSInteger modifierNumber = [mod integerValue];
            if (modifierNumber >0) {
                stickers[i] = [[STSticker alloc] initWithType:i andModifier:STSTickerModifierGood];
            }else if(modifierNumber < 0) {
                stickers[i] = [[STSticker alloc] initWithType:i andModifier:STStickerModifierBad];
            }else {
                stickers[i] = [[STSticker alloc] initWithType:i andModifier:STSTickerModifierNeutral];
            }
        }else {
            stickers[i] = [[STSticker alloc] initWithType:i andModifier:STSTickerModifierNeutral];
        }
    }
    return stickers;
}
@end
