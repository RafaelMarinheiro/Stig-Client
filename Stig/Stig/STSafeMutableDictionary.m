//
//  STSafeMutableDictionary.m
//  Stig
//
//  Created by Rafael Farias Marinheiro on 08/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STSafeMutableDictionary.h"

@implementation STSafeMutableDictionary

- (id)init
{
    if (self = [super init]) {
        lock = [[NSLock alloc] init];
        underlyingDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) setObject: (id) object forKey:(id<NSCopying>)aKey{
    [lock lock];
    @try {
        [underlyingDictionary setObject:object forKey:aKey];
    }
    @finally {
        [lock unlock];
    }
}

- (id) objectForKey:(id)aKey{
    [lock lock];
    @try {
        return [underlyingDictionary objectForKey:aKey];
    }
    @finally {
        [lock unlock];
    }
}

- (NSArray*) allValues{
    [lock lock];
    @try {
        return [underlyingDictionary allValues];
    }
    @finally {
        [lock unlock];
    }
}

- (NSInteger) count{
    [lock lock];
    @try {
        return [underlyingDictionary count];
    }
    @finally {
        [lock unlock];
    }
}

@end
