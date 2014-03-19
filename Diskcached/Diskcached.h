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

@interface NSString (MD5)

- (NSString *)diskcached_MD5Hash;

@end;



@interface Diskcached : NSObject


+ (instancetype)defaultCached;


- (id)initAtPath:(NSString *)path inUserDomainDirectory:(NSSearchPathDirectory)directory;

- (NSArray *)allKeys;

- (id)objectForKey:(id)aKey;

- (void)setObject:(id<NSCoding>)anObject forKey:(id)aKey;

- (void)removeObjectForKey:(id)aKey;
- (void)removeAllObjects;

@end