//
//  Message.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/30/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chatroom;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) Chatroom *chatroom;

@end
