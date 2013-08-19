//
//  STCheckInHistoryQueryContext.h
//  Stig
//
//  Created by Rafael Farias Marinheiro on 19/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STUser.h"

@interface STCheckInHistoryQueryContext : NSObject

@property (nonatomic, strong) STUser * user;
@property (nonatomic, strong, readonly) NSCache * cache;

- (id) initWithUser: (STUser *) user;

@end
