//
//  DiskcachedTests.m
//  DiskcachedTests
//
//  Created by Hirohisa Kawasaki on 2014/02/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Diskcached.h"

@interface DiskcachedTests : XCTestCase

@end

@implementation DiskcachedTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSetObjectForKeyAndObjectForKey
{
    NSString *str = @"test";
    Diskcached *cached = [[Diskcached alloc] init];
    [cached setObject:str forKey:@"key"];

    id result = [cached objectForKey:@"key"];
    XCTAssertNotNil(result,
                    @"result is nil");

    XCTAssertTrue([result isEqual:str],
                  @"result is not str");
}

- (void)testAllKeys
{
    Diskcached *cached = [[Diskcached alloc] init];

    NSArray *strings = @[@"http://example.com", @"test"];
    [cached setObject:strings[0] forKey:strings[0]];
    [cached setObject:strings[1] forKey:strings[1]];

    NSArray *result = [cached allKeys];

    XCTAssertTrue([result[0] isEqual:strings[0]],
                  @"result[0] %@ is fail", result[0]);

    XCTAssertTrue([result[1] isEqual:strings[1]],
                  @"result[1] %@ is fail", result[1]);
}

- (void)testRemoveObjectForKey
{
    NSString *str = @"test";
    NSString *key = @"key";
    Diskcached *cached = [[Diskcached alloc] init];
    [cached setObject:str forKey:key];

    XCTAssertNotNil([cached objectForKey:key],
                    @"Diskcached doesnt have an object");

    [cached removeObjectForKey:key];
    XCTAssertTrue([[cached allKeys] count] == 0,
                  @"`remove` is fail, Diskcached has %@", [cached allKeys]);

    XCTAssertNil([cached objectForKey:key],
                 @"Diskcached have an object");
}

- (void)testEncodeAndDecode
{
}

@end
