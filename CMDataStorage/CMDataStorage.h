//
//  CMDataStorage.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

// Safe file naming using MD5. Remove this define if you want use key as file name.
#define MD5_FOR_KEY

@interface CMDataStorage : NSObject

+ (id)sharedCacheStorage;
+ (id)sharedDocumentsStorage;
+ (id)sharedTemporaryStorage;

// Async

- (void)storeData:(NSData *)data key:(NSString *)key block:(void (^)(BOOL succeeds))block;
- (void)dataForKey:(NSString *)key block:(void (^)(NSData *data))block;
- (void)removeDataForKey:(NSString *)key block:(void (^)(BOOL succeeds))block;

// Sync

- (NSData *)dataForKey:(NSString *)key;

- (BOOL)isStored:(NSString *)key;
- (NSURL *)fileURLWithKey:(NSString *)key;
- (NSString *)filePathWithKey:(NSString *)key;

@end
