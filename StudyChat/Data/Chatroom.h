//
//  Chatroom.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/30/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Chatroom : NSManagedObject

@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * password;
@end
