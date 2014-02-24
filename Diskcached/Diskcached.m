//
//  Diskcached.m
//  Diskcached
//
//  Created by Hirohisa Kawasaki on 2014/02/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "Diskcached.h"

@implementation  NSString (Encode)

+ (NSString *)escapesString
{
    return @"!*'\"();:@&=+$,/?%#[]% ";
}

- (NSString *)stringByEscapesUsingEncoding:(NSStringEncoding)enc
{
    NSString *escapedString = (__bridge_transfer NSString *)
    CFURLCreateStringByAddingPercentEscapes(
                                            kCFAllocatorDefault,
                                            (__bridge CFStringRef)self,
                                            NULL,
                                            (CFStringRef)[NSString escapesString],
                                            CFStringConvertNSStringEncodingToEncoding(enc));
    return escapedString;
}

@end

@implementation  NSString (Decode)

- (NSString *)stringByEscapesUsingDecoding:(NSStringEncoding)enc
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

@implementation NSString (Diskcached)

+ (NSString *)stringWithCachesDirectoryAtPath:(id <NSCopying>)path
{
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    return [NSString stringWithFormat:@"%@/%@", cachesDirectory, path];
}

- (NSString *)stringByAppendingEscapesPathComponent:(NSString *)str
{
    NSString *escapedString = [str stringByEscapesUsingEncoding:NSUTF8StringEncoding];
    return [self stringByAppendingPathComponent:escapedString];
}

@end


@interface Diskcached ()

@property (nonatomic, readonly) NSString *directoryPath;

@end

@implementation Diskcached

#pragma mark - initialize

- (id)init {
    self = [super init];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize
{
    _directoryPath = [NSString stringWithCachesDirectoryAtPath:[@([self hash]) stringValue]];
    [self createDirectory];
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

    if (![self objectExistsForKey:aKey]) {
        return nil;
    }

    NSString *file = [self.directoryPath stringByAppendingEscapesPathComponent:aKey];
    NSData *data = [NSData dataWithContentsOfFile:file];
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

    NSString *file = [self.directoryPath stringByAppendingEscapesPathComponent:aKey];

    [NSKeyedArchiver archiveRootObject:anObject toFile:file];
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
    for (NSString *key in result) {
        NSString *rawString = [key stringByEscapesUsingDecoding:NSUTF8StringEncoding];
        [allKeys addObject:rawString];
    }
    return [allKeys copy];
}

- (void)removeObjectForKey:(id)aKey
{
    if (!aKey) {
        [NSException raise:NSInvalidArgumentException format:@"%s: key is nil", __func__];
    }

    NSString *file = [self.directoryPath stringByAppendingEscapesPathComponent:aKey];
    [[NSFileManager defaultManager] removeItemAtPath:file
                                               error:NULL];
}

- (void)removeAllObjects
{
    NSFileManager *manager = [NSFileManager defaultManager];

    for(NSString *filePath in [self allKeys]) {
        [manager removeItemAtPath:[self.directoryPath stringByAppendingEscapesPathComponent:filePath]
                            error:NULL];
    }
}

#pragma mark - private

- (BOOL)objectExistsForKey:(id)aKey
{
    NSString *file = [self.directoryPath stringByAppendingEscapesPathComponent:aKey];

    BOOL exists = [[NSFileManager defaultManager]
                   fileExistsAtPath:file
                   isDirectory:NULL];
    
    return exists;
}

@end