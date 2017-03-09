//
//  STNetworkOperation.h
//  Stig
//
//  Created by Lucas Tenório on 04/09/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void (^STSuccess)(AFHTTPRequestOperation * operation, id data);
typedef void (^STError)(AFHTTPRequestOperation *operation, NSError *error);

@interface STNetworkOperation : NSObject

@property (strong) NSString * path;
@property (strong) STSuccess completion;
@property (strong) STError error;

@end
