//
//  STNetworkManager.h
//  Stig
//
//  Created by Lucas Tenório on 04/09/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "STNetworkOperation.h"

@interface STNetworkManager : NSObject

@property (strong) AFHTTPClient * client;

-(void) requestFromPath: (NSString *) path completion:(STSuccess) completion error: (STError) error;

@end
