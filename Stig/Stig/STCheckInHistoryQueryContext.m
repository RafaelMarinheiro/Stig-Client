//
//  STCheckInHistoryQueryContext.m
//  Stig
//
//  Created by Rafael Farias Marinheiro on 19/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STCheckInHistoryQueryContext.h"

@implementation STCheckInHistoryQueryContext

- (id) initWithUser: (STUser *) user{
    self = [super init];
    if(self){
        _user = user;
        _cache = [[NSCache alloc] init];
    }
    return self;
}

@end
