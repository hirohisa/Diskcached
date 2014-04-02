//
//  Diskcached.h
//  Diskcached
//
//  Created by Hirohisa Kawasaki on 2014/02/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encode)

- (NSString *)diskcached_stringByEscapesUsingEncoding:(NSStringEncoding)enc;

@end

@interface NSString (Decode)

- (NSString *)diskcached_stringByEscapesUsingDecoding:(NSStringEncoding)enc;

@end

@interface Diskcached : NSObject

@property (nonatomic) BOOL cleanDiskWhenDealloc; // default is YES, if dealloc, clean data and directory
@property (nonatomic, readonly) NSString *directoryPath; // directory's path for saving objects

+ (instancetype)defaultCached;

- (id)initAtPath:(NSString *)path inUserDomainDirectory:(NSSearchPathDirectory)directory;

- (NSArray *)allKeys;

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;
- (void)removeAllObjects;

@end