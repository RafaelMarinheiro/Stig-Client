//
//  STOverlordOperationSearchFakePlace.m
//  PJPrototype
//
//  Created by Lucas Tenório on 19/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STOverlordOperationSearchFakePlace.h"

@implementation STOverlordOperationSearchFakePlace
- (id) initWithLocation:(STLocation *)location searchTerm:(NSString *)searchTerm pageNumber:(NSUInteger)pageNumber importance:(STOverlordOperationImportance)importance;{
    self = [super init];
    if (self) {
        self.location =location;
        self.searchTerm = searchTerm;
        self.pageNumber = pageNumber;
        _importance = importance;
        _cacheable = YES;
    }
    return self;
}
- (BOOL) run {
    return NO;
}
- (void) runCompletionBlock {
    self.completionBlock(self.output);
}
- (void) runErrorBlock {
    self.errorBlock(self.output);
}
@end
