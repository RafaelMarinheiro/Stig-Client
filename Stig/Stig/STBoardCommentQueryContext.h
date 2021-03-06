//
//  STBoardCommentQueryContext.h
//  Stig
//
//  Created by Rafael Farias Marinheiro on 16/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPlace.h"

@interface STBoardCommentQueryContext : NSObject

@property (nonatomic, strong) NSDate * timestamp;
@property (nonatomic, strong) STPlace * place;
@property (nonatomic, strong) NSArray * stickers;

@property (nonatomic, strong, readonly) NSCache * cache;

- (id) initWithPlace: (STPlace*) place andStickers: (NSArray *)stickers andDate: (NSDate *) date;
- (id) initWithPlace: (STPlace*) place andStickers: (NSArray *)stickers;

@end
