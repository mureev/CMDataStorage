//
//  CMDataStorage.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "CMDataStorage.h"

#define kSubfolder     @"CMStorage"

@interface CMDataStorage ()

@property (nonatomic) NSURL *cachePath;

static NSFileManager *get_file_manager();
static dispatch_queue_t get_disk_io_queue();

@end


@implementation CMDataStorage


#pragma mark - Static functions


static NSFileManager *get_file_manager() {
    static NSFileManager *sharedFileManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFileManager = [NSFileManager new];
    });
    return sharedFileManager;
}

static dispatch_queue_t get_disk_io_queue() {
    static dispatch_queue_t _diskIOQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _diskIOQueue = dispatch_queue_create("data-disk-cache.io", DISPATCH_QUEUE_CONCURRENT);
    });
    return _diskIOQueue;
}


#pragma mark - Public


+ (instancetype)sharedCacheStorage {
    static dispatch_once_t onceToken;
    static CMDataStorage *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [CMDataStorage new];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [paths[0] stringByAppendingPathComponent:kSubfolder];
        sharedInstance.cachePath = [NSURL fileURLWithPath:path isDirectory:YES];

        if (![CMDataStorage createDirectoryForURL:sharedInstance.cachePath]) {
            sharedInstance = nil;
        }
    });
    return sharedInstance;
}

+ (instancetype)sharedDocumentsStorage {
    static dispatch_once_t onceToken;
    static CMDataStorage *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [CMDataStorage new];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths[0] stringByAppendingPathComponent:kSubfolder];
        sharedInstance.cachePath = [NSURL fileURLWithPath:path isDirectory:YES];

        if (![CMDataStorage createDirectoryForURL:sharedInstance.cachePath]) {
            sharedInstance = nil;
        }
    });
    return sharedInstance;
}

+ (instancetype)sharedTemporaryStorage {
    static dispatch_once_t onceToken;
    static CMDataStorage *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [CMDataStorage new];

        sharedInstance.cachePath = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        
        [sharedInstance removeAllWithBlock:^(BOOL succeeds) {
            if (!succeeds || ![CMDataStorage createDirectoryForURL:sharedInstance.cachePath]) {
                sharedInstance = nil;
            }
        }];
    });
    return sharedInstance;
}

- (void)writeData:(NSData *)data key:(NSString *)key block:(void (^)(BOOL succeeds))block {
    NSParameterAssert(key);
    NSParameterAssert(data);
    NSAssert([key isKindOfClass:[NSString class]] && [key length] > 0, @"key");
    NSAssert([data isKindOfClass:[NSData class]] && [data length] > 0, @"data");
    
    dispatch_async(get_disk_io_queue(), ^{
        BOOL succeeds = [data writeToURL:[self fileURLWithKey:key] atomically:YES];
        
        if (!succeeds) {
            NSLog(@"Can't save data to path '%@'", [[self fileURLWithKey:key] path]);
        }
        
        if (block) {
            block(succeeds);
        }
    });
}

- (void)dataForKey:(NSString *)key block:(void (^)(NSData *data))block {
    NSParameterAssert(key);
    NSParameterAssert(block);
    NSAssert([key isKindOfClass:[NSString class]] && [key length] > 0, @"key");
    
    if ([self isStored:key]) {
        dispatch_async(get_disk_io_queue(), ^{
            NSData *data = [NSData dataWithContentsOfURL:[self fileURLWithKey:key]];
            block(data);
        });
    } else {
        block(nil);
    }
}

- (void)removeDataForKey:(NSString *)key block:(void (^)(BOOL succeeds))block {
    NSParameterAssert(key);
    NSAssert([key isKindOfClass:[NSString class]] && [key length] > 0, @"key");
    
    if ([self isStored:key]) {
        dispatch_async(get_disk_io_queue(), ^{
            BOOL succeeds = [get_file_manager() removeItemAtURL:[self fileURLWithKey:key] error:nil];
            
            if (!succeeds) {
                NSLog(@"Can't remove data to path '%@'", [[self fileURLWithKey:key] path]);
            }
            
            if (block) {
                block(succeeds);
            }
        });
    } else if (block) {
        block(YES);
    }
}

- (BOOL)writeData:(NSData *)data key:(NSString *)key {
    NSParameterAssert(key);
    NSParameterAssert(data);
    NSAssert([key isKindOfClass:[NSString class]] && [key length] > 0, @"key");
    NSAssert([data isKindOfClass:[NSData class]] && [data length] > 0, @"data");
    
    BOOL succeeds = [data writeToURL:[self fileURLWithKey:key] atomically:YES];
    
    if (!succeeds) {
        NSLog(@"Can't save data to path '%@'", [[self fileURLWithKey:key] path]);
    }
    
    return succeeds;
}

- (NSData *)dataForKey:(NSString *)key {
    NSParameterAssert(key);
    NSAssert([key isKindOfClass:[NSString class]] && [key length] > 0, @"key");
    
    if ([self isStored:key]) {
        NSData *data = [NSData dataWithContentsOfURL:[self fileURLWithKey:key]];
        return data;
    } else {
        return nil;
    }
}

- (BOOL)isStored:(NSString *)key {
    NSParameterAssert(key);
    NSAssert([key isKindOfClass:[NSString class]] && [key length] > 0, @"key");
    
    return [[self fileURLWithKey:key] checkResourceIsReachableAndReturnError:nil];
}

- (NSURL *)fileURLWithKey:(NSString *)key {
    NSParameterAssert(key);
    NSAssert([key isKindOfClass:[NSString class]] && [key length] > 0, @"key");
    
#ifdef MD5_FOR_KEY
    NSString *internalKey = [CMDataStorage internalKey:key];
    return [self.cachePath URLByAppendingPathComponent:internalKey isDirectory:NO];
#else
    return [self.cachePath URLByAppendingPathComponent:key isDirectory:NO];
#endif
}

- (NSString *)filePathWithKey:(NSString *)key {
    NSParameterAssert(key);
    NSAssert([key isKindOfClass:[NSString class]] && [key length] > 0, @"key");
    
    return [[self fileURLWithKey:key] path];
}

- (NSArray*)allKeysURLs {
    NSArray *dirContents = [get_file_manager() contentsOfDirectoryAtURL:self.cachePath includingPropertiesForKeys:nil options:0 error:nil];
    return dirContents;
}

- (NSArray*)allKeysPaths {
    NSArray *dirContents = [get_file_manager() contentsOfDirectoryAtPath:[self.cachePath path] error:nil];
    return dirContents;
}

- (void)removeAllWithBlock:(void (^)(BOOL succeeds))block; {
    dispatch_async(get_disk_io_queue(), ^{
        BOOL succeeds = [CMDataStorage removeDirectoryForURL:self.cachePath];
        
        if (succeeds) {
            succeeds = [CMDataStorage createDirectoryForURL:self.cachePath];
        }
        
        if (block) {
            block(succeeds);
        }
    });
}


#pragma mark - Private


+ (NSString *)internalKey:(NSString *)key {
    const char *ptr = [key UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", md5Buffer[i]];
    }

    return output;
}

+ (BOOL)removeDirectoryForURL:(NSURL *)dirPath {
    NSError *error = nil;
    [get_file_manager() removeItemAtURL:dirPath error:&error];
    
    if (error) {
        NSLog(@"Fail to remove storage directory '%@'", [error localizedDescription]);
    }
    
    return !error;
}

+ (BOOL)createDirectoryForURL:(NSURL *)dirPath {
    NSError *error = nil;
    [get_file_manager() createDirectoryAtURL:dirPath withIntermediateDirectories:YES attributes:nil error:&error];

    if (error) {
        NSLog(@"Fail to create storage directory '%@'", [error localizedDescription]);
    }

    return !error;
}

@end
