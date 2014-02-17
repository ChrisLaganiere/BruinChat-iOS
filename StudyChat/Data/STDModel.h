//
//  STDModel.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/31/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STDModel : NSObject

+(STDModel *)sharedInstance;
-(BOOL)addClassToCoreDataWithTitle:(NSString *)title Subtitle:(NSString *)subtitle Jid:(NSString *)jid;
-(BOOL)cleanUpAfterClassWithJid:(NSString *)jid;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveChanges;
- (void)cancelChanges;

@end
