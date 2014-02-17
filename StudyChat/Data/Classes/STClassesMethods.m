//
//  STClassesMethods.m
//  BruinChat
//
//  Created by Christopher Laganiere on 2/16/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "STClassesMethods.h"
#import "AFHTTPRequestOperationManager.h"
#import "STAddChats_ClassesViewController.h"

@interface STClassesMethods()

@end

@implementation STClassesMethods

static NSDictionary *_currentSubjectAreas = nil;

+(NSDictionary *)currentSubjectAreas
{
    if(!_currentSubjectAreas) {
        _currentSubjectAreas = [[NSDictionary alloc] init];
        [self requestCurrentSubjectAreas];
    }
    return _currentSubjectAreas;
}

+(void)requestCurrentSubjectAreas
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://www.chrislaganiere.com/bruinchat/json/subject-areas.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            _currentSubjectAreas = responseObject;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
+(void)populateClassesForSubjectArea:(NSString *)subjectArea sender:(STAddChats_ClassesViewController *)sender
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *currentQuarter = @"14W";
    NSString *URL = [NSString stringWithFormat:@"http://www.chrislaganiere.com/bruinchat/json/%@/%@.json",currentQuarter,subjectArea];
    
    [manager GET:[URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"success");
            if ([sender isViewLoaded])
                [sender populateClasses:responseObject[@"courses"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
     
    
}

@end
