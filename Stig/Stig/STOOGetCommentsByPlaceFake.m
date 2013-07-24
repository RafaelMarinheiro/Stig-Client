//
//  STOverlordOperationGetCommentsByPlaceFake.m
//  PJPrototype
//
//  Created by Lucas Tenório on 19/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STOOGetCommentsByPlaceFake.h"


@implementation STOOGetCommentsByPlaceFake


- (id) initWithLocation:(STLocation *)location place:(STPlace *)place stickers:(NSArray *)stickers pageNumber:(NSUInteger)pageNumber importance:(STOverlordOperationImportance)importance completion:(void (^)(NSArray *, NSUInteger))completionBlock error:(STOOErrorBlock)errorBlock{
    self = [super init];

    if (self) {
        self.location = location;
        self.place = place;
        self.pageNumber = pageNumber;
        self.completionBlock = completionBlock;
        self.errorBlock = errorBlock;
        self.stickers = stickers;
        _importance = importance;
        _cacheable = YES;
    }
    return self;
}

- (BOOL) run {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fakeComments" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError * error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        _output = error;
        return NO;
    }else {
        NSDictionary *main = json;
        NSArray *comments = main[@"comments"];
        NSMutableArray *resolvedComments = [NSMutableArray arrayWithCapacity:[comments count]];

        for (NSDictionary *commentDictionary in comments) {
            STBoardComment *comment = [STBoardComment boardCommentFromJSONData:commentDictionary];
            if (comment) {
                if ([comment.placeId isEqualToNumber:self.place.placeId]) {
                    [resolvedComments addObject:comment];
                }
            }else {
                _output = [NSError errorWithDomain:@"resolving comment json" code:3 userInfo:nil];
                return NO;
            }
        }
        _output = resolvedComments;
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
