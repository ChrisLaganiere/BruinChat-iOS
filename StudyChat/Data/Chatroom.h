//
//  Chatroom.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/30/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message, User;

@interface Chatroom : NSManagedObject

@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * maxUsers;
@property (nonatomic, retain) NSSet *message;
@end

@interface Chatroom (CoreDataGeneratedAccessors)

- (void)addMessageObject:(Message *)value;
- (void)removeMessageObject:(Message *)value;
- (void)addMessage:(NSSet *)values;
- (void)removeMessage:(NSSet *)values;

@end
