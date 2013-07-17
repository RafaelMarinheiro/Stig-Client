//
//  STRanking.h
//  PJPrototype
//
//  Created by Lucas Tenório on 17/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STRanking : NSObject
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSNumber *social;
@property (nonatomic, strong) NSNumber *buzz;
@property (nonatomic, strong) NSNumber *overall;

+ (STRanking *) rankingFromJSONData:(id) json;
@end
