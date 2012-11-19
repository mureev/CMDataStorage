//
//  CMDataStorage.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface CMDataStorage : NSObject

+ (id)sharedCacheStorage;
+ (id)sharedDocumentsStorage;
+ (id)sharedTemporaryStorage;

- (void)storeData:(NSData *)data key:(NSString *)key block:(void (^)(BOOL succeeds))block;
- (void)dataForKey:(NSString *)key block:(void (^)(NSData *data))block;
- (void)removeDataForKey:(NSString *)key block:(void (^)(BOOL succeeds))block;

- (BOOL)isCached:(NSString *)key;
- (NSURL *)fileURLWithKey:(NSString *)key;
- (NSString *)filePathWithKey:(NSString *)key;

@end
