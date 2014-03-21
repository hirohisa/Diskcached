//
//  NSString+MD5.m
//  Diskcached
//
//  Created by Hirohisa Kawasaki on 2014/03/22.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (NSString *)diskcached_MD5Hash
{
    const char *charString = [self UTF8String];
    unsigned char result[16];
    CC_MD5(charString, (unsigned int)strlen(charString), result);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

@end
