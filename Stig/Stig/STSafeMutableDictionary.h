//
//  STSafeMutableDictionary.h
//  Stig
//
//  Created by Rafael Farias Marinheiro on 08/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STSafeMutableDictionary : NSObject
{
@private
    NSLock *lock;
    NSMutableDictionary *underlyingDictionary;
}

- (void) setObject: (id) object forKey:(id<NSCopying>)aKey;

- (id) objectForKey:(id)aKey;
- (NSArray*) allValues;
- (NSInteger) count;
@end