//
//  STDataOverlord.m
//  PJPrototype
//
//  Created by Rafael Marinheiro on 08/08/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

/*

#import "STOverlord.h"
#import "STOOGetPlacesFake.h"
#import "STOOResolveUserByIDFake.h"
#import "STOOResolveCommentsByIdFake.h"
#import "STOOResolvePlaceByIdFake.h"
#import "STOOGetCommentsByPlaceFake.h"



//The last implementation of the Overlord. Now with lasers
@implementation STOverlord

#pragma mark-
#pragma mark Initialization

+ (id) sharedInstance {
    static STOverlord *overlord = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        overlord = [[self alloc] init];
    });
    return overlord;
}


@end
 
 */

#import "STOverlord.h"
#import "STFakeOverlord.h"
#import "STNetworkingOverlord.h"

static STOverlordType _defaultType = STOverlordTypeLocalJson;
static id<STOverlord> _overlords[STOverlordTypeNumbers];
static dispatch_once_t onceToken[STOverlordTypeNumbers];

@implementation STHiveCluster

+ (void) setDefaultOverlordType: (STOverlordType) type{
    _defaultType = type;
}

+ (id<STOverlord>) spawnOverlord{
    return [STHiveCluster spawnOverlordWithType:_defaultType];
}

+ (id<STOverlord>) spawnOverlordWithType:(STOverlordType) type{
    if(_overlords[type] == nil){
        dispatch_once(&onceToken[type], ^{
            if(type == STOverlordTypeLocalJson){
                _overlords[type] = [[STFakeOverlord alloc] init];
            } else if(type == STOverlordTypeNetworked){
                _overlords[type] = [[STNetworkingOverlord alloc] init];
            }
        });
    }
    return _overlords[type];
}

@end
