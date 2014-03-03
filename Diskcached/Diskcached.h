//
//  Diskcached.h
//  Diskcached
//
//  Created by Hirohisa Kawasaki on 2014/02/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encode)

- (NSString *)stringByEscapesUsingEncoding:(NSStringEncoding)enc;

@end

@interface NSString (Decode)

- (NSString *)stringByEscapesUsingDecoding:(NSStringEncoding)enc;

@end

@interface Diskcached : NSObject

+ (instancetype)defaultCached;

- (NSArray *)allKeys;

- (id)objectForKey:(id)aKey;

- (void)setObject:(id<NSCoding>)anObject forKey:(id)aKey;

- (void)removeObjectForKey:(id)aKey;
- (void)removeAllObjects;

@end