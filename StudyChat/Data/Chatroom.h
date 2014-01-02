//
//  Chatroom.h
//  BruinChat
//
//  Created by Christopher Laganiere on 1/2/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chatroom : NSManagedObject

@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;

@end
