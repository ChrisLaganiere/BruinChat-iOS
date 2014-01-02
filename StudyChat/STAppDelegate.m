//
//  STAppDelegate.m
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STAppDelegate.h"
#import "SSKeychain.h"
#import "STLoginViewController.h"

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "GCDAsyncSocket.h"
#import <CFNetwork/CFNetwork.h>
#import "XMPPReconnect.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPCapabilitiesCoreDataStorage.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@interface STAppDelegate()
- (void)setupStream;
- (void)goOnline;
- (void)goOffline;
@end

@implementation STAppDelegate

@synthesize xmppStream;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [self.xmppRosterStorage mainThreadManagedObjectContext];
}
- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream {
    if (!xmppStream) {
        NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
        xmppStream = [[XMPPStream alloc] init];
        [xmppStream setHostName:HostName];
        [xmppStream setHostPort:5222];
        
        // Setup reconnect
        //
        // The XMPPReconnect module monitors for "accidental disconnections" and
        // automatically reconnects the stream for you.
        // There's a bunch more information in the XMPPReconnect header file.
        self.xmppReconnect = [[XMPPReconnect alloc] init];
        
        // Setup roster
        //
        // The XMPPRoster handles the xmpp protocol stuff related to the roster.
        // The storage for the roster is abstracted.
        // So you can use any storage mechanism you want.
        // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
        // or setup your own using raw SQLite, or create your own storage mechanism.
        // You can do it however you like! It's your application.
        // But you do need to provide the roster with some storage facility.
        
        self.xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
        //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
        
        self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];
        
        self.xmppRoster.autoFetchRoster = YES;
        self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
        
        // Setup vCard support
        //
        // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
        // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
        
        xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
        xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
        xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
        
        // Setup capabilities
        //
        // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
        // Basically, when other clients broadcast their presence on the network
        // they include information about what capabilities their client supports (audio, video, file transfer, etc).
        // But as you can imagine, this list starts to get pretty big.
        // This is where the hashing stuff comes into play.
        // Most people running the same version of the same client are going to have the same list of capabilities.
        // So the protocol defines a standardized way to hash the list of capabilities.
        // Clients then broadcast the tiny hash instead of the big list.
        // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
        // and also persistently storing the hashes so lookups aren't needed in the future.
        //
        // Similarly to the roster, the storage of the module is abstracted.
        // You are strongly encouraged to persist caps information across sessions.
        //
        // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
        // It can also be shared amongst multiple streams to further reduce hash lookups.
        
        xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
        xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
        
        xmppCapabilities.autoFetchHashedCapabilities = YES;
        xmppCapabilities.autoFetchNonHashedCapabilities = NO;
        
        // Setup message archiving
        //
        /**
         * XEP-0136 Message Archiving outlines a complex protocol for:
         *
         *  - archiving messages on the xmpp server
         *  - allowing the client to sync it's client-side cache with the server side archive
         *  - allowing the client to configure archiving preferences (default, per contact, etc)
         *
         * There are times when this complication isn't necessary or possible.
         * E.g. the server doesn't support the message archiving protocol.
         *
         * In this case you can simply set clientSideMessageArchivingOnly to YES,
         * and this instance won't bother with any of the server protocol stuff.
         * It will simply arhive outgoing and incoming messages.
         *
         * Note: Even when clientSideMessageArchivingOnly is YES,
         *       you can still take advantage of the preference methods to configure various options,
         *       such as how long to store messages, prefs for individual contacts, etc.
         **/
        xmppMessageArchivingStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        xmppMessageArchivingModule = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:xmppMessageArchivingStorage];
        [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
        
        
        // Activate xmpp modules
        [self.xmppReconnect activate:xmppStream];
        [self.xmppRoster activate:xmppStream];
        [xmppvCardTempModule   activate:xmppStream];
        [xmppvCardAvatarModule activate:xmppStream];
        [xmppCapabilities      activate:xmppStream];
        [xmppMessageArchivingModule activate:xmppStream];
        
        // Add ourself as a delegate to anything we may be interested in
        
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [xmppMessageArchivingModule  addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
}
- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[self.xmppRoster removeDelegate:self];
	
	[self.xmppReconnect    deactivate];
	[self.xmppRoster       deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
    
	xmppStream = nil;
	self.xmppReconnect = nil;
    self.xmppRoster = nil;
	self.xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}
- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}
- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}
- (BOOL)connect:(NSString *)userID withPass:(NSString *)userPass
{
    
    [self setupStream];
    if (![xmppStream isAuthenticated]) {
        NSLog(@"not authenticated yet...");
    }
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    NSLog(@"trying to connect");
    
    if (userID == nil || userPass == nil) {
        return NO;
    }
    
    NSString *hostName = HostName;
    NSString *jID = [NSString stringWithFormat:@"%@@%@",userID,hostName];
    [xmppStream setMyJID:[XMPPJID jidWithString:jID]];
    password = userPass;
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:5.0 error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    }
    return YES;
}
-(void)autoConnect
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autoLoginDisabled"]) {
        //credentials saved, connect without prompt
        NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"];
        NSString *userPass = [SSKeychain passwordForService:@"xmpp" account:userID];
        if (![self connect:userID withPass:userPass]) {
            //couldn't connect
            [self teardownAndDismissAllButLogin];
        }
    }
    else {
        NSLog(@"AUTO LOGIN DISABLED");
        [self teardownAndDismissAllButLogin];
    }
}
-(void)teardownAndDismissAllButLogin
{
    [self teardownStream];
    
    UIViewController *topController = self.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
        [topController dismissViewControllerAnimated:NO completion:nil];
        topController = self.window.rootViewController;
    }
    NSLog(@"teardownAndDismissAllButLogin finished");
}
- (void)disconnect {
    [self goOffline];
    [xmppStream disconnect];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    isOpen = YES;
    NSError *error = nil;
    NSLog(@"xmppStreamDidConnect");
    if (![[self xmppStream] authenticateWithPassword:password error:&error]) {
        NSLog(@"error: %@",error);
        DDLogError(@"Error authenticating: %@", error);
    }
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if (self._loginDelegate) {
        [self._loginDelegate loginSucceeded];
        self._loginDelegate = nil;
    }
    [self goOnline];
    //[self getListOfChatrooms];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    [xmppStream disconnect];
    if (self._loginDelegate)
    {
        [self._loginDelegate loginFailed];
        self._loginDelegate = nil;
    }
    else {
        NSLog(@"no loginDelegate!");
    }
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

/*
//////XMPP GROUPCHAT TRIAL (currently unused)
-(void)getListOfChatrooms
{
    NSString* server = @"conference.bruinchat.p1.im"; //or whatever the server address for muc is
    XMPPJID *servrJID = [XMPPJID jidWithString:server];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[xmppStream myJID].full];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [xmppStream sendElement:iq];
}
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    NSLog(@"CHAT ROOM LIST??");
    DDLogVerbose(@"%@", [iq description]);
    return NO;
}

//////////
*/
 
- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    [self disconnect];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    [self autoConnect];
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody])
	{
        
		//XMPPUserCoreDataStorageObject *user = [self.xmppRosterStorage userForJID:[message from] xmppStream:xmppStream managedObjectContext:[self managedObjectContext_roster]];
        
        NSLog(@"message received");
        
        /*
        NSString *msg = [[message elementForName:@"body"] stringValue];
		//NSString *from = [user displayName];
        NSString *from = [[message attributeForName:@"from"] stringValue];
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:msg forKey:@"msg"];
        [m setObject:from forKey:@"sender"];
         */
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	XMPPUserCoreDataStorageObject *user = [self.xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}
	
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Not implemented"
		                                          otherButtonTitles:nil];
		[alertView show];
	}
	else
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
