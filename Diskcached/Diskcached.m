//
//  Diskcached.m
//  Diskcached
//
//  Created by Hirohisa Kawasaki on 2014/02/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "Diskcached.h"
#import <CommonCrypto/CommonDigest.h>

@implementation  NSString (Encode)

+ (NSString *)diskcached_escapesString
{
    return @"!*'\"();:@&=+$,/?%#[]% ";
}

- (NSString *)diskcached_stringByEscapesUsingEncoding:(NSStringEncoding)enc
{
    NSString *escapedString = (__bridge_transfer NSString *)
    CFURLCreateStringByAddingPercentEscapes(
                                            kCFAllocatorDefault,
                                            (__bridge CFStringRef)self,
                                            NULL,
                                            (CFStringRef)[NSString diskcached_escapesString],
                                            CFStringConvertNSStringEncodingToEncoding(enc));
    return escapedString;
}

@end

@implementation  NSString (Decode)

- (NSString *)diskcached_stringByEscapesUsingDecoding:(NSStringEncoding)enc
{
    NSString *rawString = (__bridge_transfer NSString *)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                            kCFAllocatorDefault,
                                                            (CFStringRef)self,
                                                            CFSTR(""),
                                                            CFStringConvertNSStringEncodingToEncoding(enc));
    return rawString;
}

@end

@implementation NSString (MD5)

- (NSString *)diskcached_MD5Hash
{
    const char *charString = [self UTF8String];

    unsigned char result[16];
    CC_MD5(charString, strlen(charString), result);

    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

@end

@implementation NSString (Diskcached)

+ (NSString *)diskcached_stringWithPath:(NSString *)path inUserDomainDirectory:(NSSearchPathDirectory)searchPathDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:path];
}

- (NSString *)diskcached_stringByAppendingEscapesPathComponent:(NSString *)str
{
    NSString *escapedString = [str diskcached_stringByEscapesUsingEncoding:NSUTF8StringEncoding];
    return [self stringByAppendingPathComponent:escapedString];
}

@end

@interface DiskcachedOperation : NSOperation

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSString *file;
@property (nonatomic, copy) void (^completionBlock)();

@end

@implementation DiskcachedOperation

- (id)initWithData:(NSData *)data AtFile:(NSString *)file
{
    self = [super init];
    if (self) {
        _data = data;
        _file   = file;
    }
    return self;
}

- (void)main
{
    [self.data writeToFile:self.file atomically:NO];
    if (self.completionBlock) {
        self.completionBlock();
    }
}

- (void)cancel
{
    [super cancel];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:self.file
                                               error:&error];
    _data = nil;
    _file = nil;
    if (error) {
        NSLog(@"error %@", error);
    }
}

@end


@interface Diskcached ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, readonly) NSString *directoryPath;

@end

@implementation Diskcached


#pragma mark - default instance, singleton

+ (instancetype)defaultCached {
    static Diskcached *_defaultCached = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultCached = [[self alloc] initAtPath:@"Diskcached" inUserDomainDirectory:NSCachesDirectory];
    });

    return _defaultCached;
}

#pragma mark - initialize

- (id)init
{
    NSString *path = [NSString stringWithFormat:@"%@%@",
                      NSStringFromClass([self class]),
                      [@([self hash]) stringValue]];
    return [self initAtPath:path inUserDomainDirectory:NSCachesDirectory];
}

- (id)initAtPath:(NSString *)path inUserDomainDirectory:(NSSearchPathDirectory)directory
{
    self = [super init];
    if (self) {
        _directoryPath = [NSString diskcached_stringWithPath:path inUserDomainDirectory:directory];
        [self diskcached_configure];
    }
    return self;
}


- (void)diskcached_configure
{
    // create directory
    [self createDirectory];

    // operation queue
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
}

- (BOOL)createDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // already exist
    if ([fileManager fileExistsAtPath:self.directoryPath]) {
        return NO;
    }

    return [fileManager createDirectoryAtPath:self.directoryPath
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:NULL];
}

- (void)dealloc
{
    [self removeAllObjects];
    [[NSFileManager defaultManager] removeItemAtPath:self.directoryPath error:NULL];
}

#pragma mark - public

- (id)objectForKey:(id)aKey
{
    if (!aKey) {
        [NSException raise:NSInvalidArgumentException format:@"%s: key is nil", __func__];
    }

    NSString *file = [self.directoryPath diskcached_stringByAppendingEscapesPathComponent:aKey];

    NSData *data;
    for (DiskcachedOperation *operation in self.operationQueue.operations) {
        if ([operation.file isEqual:file]) {
            data = operation.data;
        }
    }

    if (!data &&
        [self objectExistsAtFile:file]) {
        data = [NSData dataWithContentsOfFile:file];
    }

    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    return nil;
}

- (void)setObject:(id<NSCoding>)anObject forKey:(id)aKey
{
    if (!aKey ||
        !anObject) {
        [NSException raise:NSInvalidArgumentException format:@"%s: object or key is nil", __func__];
    }

    NSString *file = [self.directoryPath diskcached_stringByAppendingEscapesPathComponent:aKey];
    NSData   *data = [NSKeyedArchiver archivedDataWithRootObject:anObject];
    DiskcachedOperation *operation = [[DiskcachedOperation alloc] initWithData:data AtFile:file];

    [self.operationQueue addOperation:operation];
}

- (NSArray *)allKeys
{
    NSError *error = nil;
    id result = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryPath
                                                                     error:&error];
    if (error) {
        return nil;
    }

    NSMutableArray *allKeys = [@[] mutableCopy];
    for (DiskcachedOperation *operation in self.operationQueue.operations) {
        if ([operation isExecuting] && ![operation isCancelled]) {
            NSString *rawString = [[operation.file lastPathComponent] diskcached_stringByEscapesUsingDecoding:NSUTF8StringEncoding];
            [allKeys addObject:rawString];
        }
    }
    for (NSString *key in result) {
        NSString *rawString = [key diskcached_stringByEscapesUsingDecoding:NSUTF8StringEncoding];
        [allKeys addObject:rawString];
    }
    return [allKeys copy];
}

- (void)removeObjectForKey:(id)aKey
{
    if (!aKey) {
        [NSException raise:NSInvalidArgumentException format:@"%s: key is nil", __func__];
    }

    NSString *file = [self.directoryPath diskcached_stringByAppendingEscapesPathComponent:aKey];

    for (DiskcachedOperation *operation in self.operationQueue.operations) {
        if ([operation.file isEqual:file]) {
            [operation cancel];
        }
    }
    [[NSFileManager defaultManager] removeItemAtPath:file
                                               error:NULL];
}

- (void)removeAllObjects
{
    NSFileManager *manager = [NSFileManager defaultManager];

    for(NSString *filePath in [self allKeys]) {
        [manager removeItemAtPath:[self.directoryPath diskcached_stringByAppendingEscapesPathComponent:filePath]
                            error:NULL];
    }
}

#pragma mark - private

- (BOOL)objectExistsAtFile:(NSString *)file
{
    BOOL exists = [[NSFileManager defaultManager]
                   fileExistsAtPath:file
                   isDirectory:NULL];
    
    return exists;
}

@end