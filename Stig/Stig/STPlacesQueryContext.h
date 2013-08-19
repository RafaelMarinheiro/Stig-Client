//
//  STPlacesQueryContext.h
//  Stig
//
//  Created by Rafael Farias Marinheiro on 19/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STPlacesQueryContext : NSObject

@property (nonatomic, strong) NSString * queryString;
@property (nonatomic, strong, readonly) NSCache * cache;

- (id) initWithQueryString: (NSString *) query;

@end
