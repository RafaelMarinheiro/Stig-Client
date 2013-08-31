//
//  STSticker.h
//  Stig
//
//  Created by Lucas Tenório on 08/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    STStickerTypeMoney = 0,
    STStickerTypeFood = 1,
    STStickerTypeQueue= 2,
    STStickerTypeMusic = 3,
    STStickerTypeAccessibility = 4,
    STStickerTypePeople = 5
}STStickerType;
typedef enum {
    STStickerModifierBad = 0,
    STSTickerModifierNeutral = 1,
    STSTickerModifierGood = 2
}STSTickerModifier;
@interface STSticker : NSObject
@property (nonatomic, readonly) STStickerType type;
@property (nonatomic, readonly) STSTickerModifier modifier;
@property (nonatomic, readonly) NSNumber *stickerId;
- (id) initWithType:(STStickerType) type andModifier:(STSTickerModifier) modifier;
- (id) initWithId:(NSNumber *) stickerId;
- (UIImage *) stickerIconWithPlace:(NSString *) place;
- (NSUInteger) getServerCode;

+ (NSArray *) stickersWithServerCode: (NSUInteger) code;
+ (NSUInteger) stickersServeCodeFromArray: (NSArray *) array;
+ (NSUInteger) stickersServerQueryCodeFromArray: (NSArray*) array;
+ (NSArray *) stickersWithStatusDictionary:(NSDictionary *) dictionary;

@end
