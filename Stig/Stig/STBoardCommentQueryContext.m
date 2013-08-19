//
//  STBoardCommentQueryContext.m
//  Stig
//
//  Created by Rafael Farias Marinheiro on 16/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STBoardCommentQueryContext.h"

@implementation STBoardCommentQueryContext

- (id)initWithPlace: (STPlace*) place andStickers: (NSArray *)stickers andDate: (NSDate *) date{
    self = [super init];
    if(self){
        _place = place;
        _stickers = stickers;
        _timestamp = date;
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (id)initWithPlace: (STPlace*) place andStickers: (NSArray *)stickers{
    return [self initWithPlace:place andStickers:stickers andDate:[[NSDate alloc] init]];
}

@end
