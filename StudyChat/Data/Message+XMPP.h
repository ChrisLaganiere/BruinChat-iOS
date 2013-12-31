//
//  Message+XMPP.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/30/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "Message.h"
@class XMPPMessage;

@interface Message (XMPP)
+(Message *)newMessageWithXMPPInfo:(XMPPMessage *)message inManagedObjectContext:(NSManagedObjectContext *)context;
@end
