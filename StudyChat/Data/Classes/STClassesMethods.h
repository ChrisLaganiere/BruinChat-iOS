//
//  STClassesMethods.h
//  BruinChat
//
//  Created by Christopher Laganiere on 2/16/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STAddChats_ClassesViewController;

@interface STClassesMethods : NSObject

+(NSDictionary *)currentSubjectAreas;
+(void)populateClassesForSubjectArea:(NSString *)subjectArea sender:(STAddChats_ClassesViewController *)sender;

@end