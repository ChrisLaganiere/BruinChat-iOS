//
//  Message+XMPP.m
//  BruinChat
//
//  Created by Christopher Laganiere on 12/30/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "Message+XMPP.h"
#import "XMPPMessage.h"
#import "XMPP.h"
#import "STAppDelegate.h"
#import "NSString+Utils.h"

@implementation Message (XMPP)

+(Message *)newMessageWithXMPPInfo:(XMPPMessage *)message inManagedObjectContext:(NSManagedObjectContext *)context
{
    Message *messageObject = nil;
    
    NSString *uniqueID = [[message attributeForName:@"id"] stringValue];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@",uniqueID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //handle error
    } else if ([matches count]) {
        messageObject = [matches firstObject];
    } else {
        //create new message object
        messageObject = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
        messageObject.id = uniqueID;
        messageObject.from = [[message attributeForName:@"from"] stringValue];
        messageObject.to = [[message attributeForName:@"to"] stringValue];
        messageObject.body = [[message elementForName:@"body"] stringValue];
        messageObject.time = [NSString getCurrentTime];
    }
    
    return messageObject;
}

@end
