//
//  STPlacesQueryContext.m
//  Stig
//
//  Created by Rafael Farias Marinheiro on 19/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STPlacesQueryContext.h"

@implementation STPlacesQueryContext

- (id) initWithQueryString: (NSString *) query{
    self = [super init];
    if(self){
        _queryString = query;
        _cache = [[NSCache alloc] init];
    }
    return self;
}

@end
