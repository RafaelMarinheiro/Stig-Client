//
//  STNetworkManager.m
//  Stig
//
//  Created by Lucas Tenório on 04/09/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STNetworkManager.h"

@implementation STNetworkManager{
    NSLock * _lock;
    NSMutableDictionary * _dic;
}

-(id) init{
    self = [super init];
    if(self){
        _lock = [[NSLock alloc] init];
        _dic = [[NSMutableDictionary alloc] init];
        _client = nil;
    }
    return self;
}

-(void) requestFromPath:(NSString *)path completion:(STSuccess)completion error:(STError)error{
    STNetworkOperation * noperation = [[STNetworkOperation alloc] init];
    noperation.path = path;
    noperation.completion = completion;
    noperation.error = error;
    [_lock lock];
        NSMutableArray * arr = [_dic objectForKey:noperation.path];
        if(arr == nil){
            arr = [[NSMutableArray alloc] initWithObjects:noperation, nil];
            [_dic setValue:arr forKey:noperation.path];
            NSMutableURLRequest * request = [_client requestWithMethod:@"GET" path: noperation.path parameters:nil];
            AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

            NSLog(@"Requesting to %@", noperation.path);
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                [_lock lock];
                    NSMutableArray * list = [_dic objectForKey:noperation.path];
                    [_dic removeObjectForKey:noperation.path];
                [_lock unlock];
                for(STNetworkOperation * koperation in list){
                    koperation.completion(operation, responseObject);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [_lock lock];
                    NSMutableArray * list = [_dic objectForKey:noperation.path];
                    [_dic removeObjectForKey:noperation.path];
                [_lock unlock];
                for(STNetworkOperation * koperation in list){
                    koperation.error(operation, error);
                }
            }];
            [_client enqueueHTTPRequestOperation:operation];
            
        } else{
            [arr addObject:noperation];
        }
    [_lock unlock];
}

@end
