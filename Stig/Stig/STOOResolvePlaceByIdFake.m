//
//  STOOResolvePlaceByIdFake.m
//  PJPrototype
//
//  Created by Lucas Tenório on 20/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STOOResolvePlaceByIdFake.h"

@implementation STOOResolvePlaceByIdFake 

- (id) initWithPlaceId:(NSNumber *) placeId importance:(STOverlordOperationImportance)importance completion:(STOOResolveCompletionBlock)completionBlock error:(STOOErrorBlock)errorBlock{
    self = [super init];
    if (self) {
        _placeId = placeId;
        _importance = importance;
        _cacheable = YES;
        self.completionBlock = completionBlock;
        self.errorBlock = errorBlock;
        
    }
    return self;
}

- (BOOL) run {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fakePlaces" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError * error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (json) {
        NSDictionary *mainDictionary = json;
        NSArray *placesJSON = mainDictionary[@"places"];
        for (NSDictionary *placeDictionary in placesJSON) {
            NSNumber *placeId = placeDictionary[@"id"];
            if ([placeId isEqualToNumber:self.placeId]) {
                STPlace *place = [STPlace placeFromJSONData:placeDictionary];
                _output = place;
                return YES;
            }
        }
        _output = [NSError errorWithDomain:@"place not found or error in json" code:2 userInfo:nil];
        return NO;
    }  else {
        _output = error;
        return NO;
    }
}

- (void) runCompletionBlock {
    self.completionBlock(self.output);
}
- (void) runErrorBlock {
    self.errorBlock(self.output);
}

@end
