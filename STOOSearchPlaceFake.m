//
//  STOverlordOperationSearchFakePlace.m
//  PJPrototype
//
//  Created by Lucas Tenório on 19/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STOOSearchPlaceFake.h"

@implementation STOOSearchPlaceFake
- (id) initWithLocation:(STLocation *)location searchTerm:(NSString *)searchTerm pageNumber:(NSUInteger)pageNumber importance:(STOverlordOperationImportance)importance completion:(void (^)(NSArray *places, NSUInteger page)) completionBlock
                  error:(STOErrorBlock) errorBlock{
    self = [super init];
    if (self) {
        self.location =location;
        self.searchTerm = searchTerm;
        self.pageNumber = pageNumber;
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
    if (error) {
        _output = error;
        return NO;
    }else {
        NSDictionary *main = json;
        NSArray *places = main[@"places"];
        NSMutableArray *resolvedPlaces = [NSMutableArray arrayWithCapacity:[places count]];

        for (NSDictionary *placeDictionary in places) {
            STPlace *place = [STPlace placeFromJSONData:placeDictionary];
            if (place) {
                [resolvedPlaces addObject:place];
            }else {
                _output = [NSError errorWithDomain:@"resolving json" code:3 userInfo:nil];
                return NO;
            }
        }
        _output = resolvedPlaces;
        return YES;
    }
}
- (void) runCompletionBlock {
    self.completionBlock(self.output, 0);
}
- (void) runErrorBlock {
    self.errorBlock(self.output);
}
@end
