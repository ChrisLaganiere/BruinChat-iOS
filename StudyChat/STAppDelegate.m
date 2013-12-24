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

#import "XMPP.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "GCDAsyncSocket.h"
#import <CFNetwork/CFNetwork.h>

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
@synthesize _chatDelegate, _messageDelegate;

- (void)setupStream {
    if (!xmppStream) {
        NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
        xmppStream = [[XMPPStream alloc] init];
        [xmppStream setHostName:@"localhost"];
        [xmppStream setHostPort:5222];
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
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
    
    NSString *hostName = @"@chris.local";
    NSString *jID = [NSString stringWithFormat:@"%@%@",userID,hostName];
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
            [self dismissAllButLogin];
        }
    }
    else {
        NSLog(@"AUTO LOGIN DISABLED");
        [self dismissAllButLogin];
    }
}
-(void)dismissAllButLogin
{
    self._chatDelegate = nil;
    self._messageDelegate = nil;
    
    UIViewController *topController = self.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
        [topController dismissViewControllerAnimated:NO completion:nil];
        topController = self.window.rootViewController;
    }
    NSLog(@"dismissAllButLogin finished");
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

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    [self disconnect];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    [self autoConnect];
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:myUsername]) {
        if ([presenceType isEqualToString:@"available"]) {
            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"chris.local"]];
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"chris.local"]];
        }
    }
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody])
	{
        NSLog(@"message received");
        NSString *msg = [[message elementForName:@"body"] stringValue];
        NSLog(@"msg: %@",msg);
        NSString *from = [[message attributeForName:@"from"] stringValue];
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:msg forKey:@"msg"];
        [m setObject:from forKey:@"sender"];
        [_messageDelegate newMessageReceived:m];
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
