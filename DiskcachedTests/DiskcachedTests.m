//
//  DiskcachedTests.m
//  DiskcachedTests
//
//  Created by Hirohisa Kawasaki on 2014/02/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Diskcached.h"

@interface Diskcached ()

@property (nonatomic, readonly) NSString *directoryPath;

@end

@interface TestDiskcached : Diskcached
@end

@implementation TestDiskcached
@end

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
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
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
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
}

- (void)testCleanDiskWhenDealloced
{
    NSString *str = @"test";
    NSString *key = @"key";
    NSString *directoryPath;

    Diskcached *cached = [[Diskcached alloc] init];
    directoryPath = cached.directoryPath;

    [cached setObject:str forKey:key];

    XCTAssertNotNil([cached objectForKey:key],
                    @"Diskcached doesnt have an object");
    cached = nil;

    // validate to have files in directoy
    id contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
    XCTAssertNil(contents,
                 @"`dealloc` is fail, files exists, %@", contents);

    // validate to exist directoy
    BOOL isDirectory = NO;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDirectory];

    XCTAssertTrue(!fileExists,
                  @"`dealloc` is fail, directory exists, %@", directoryPath);
    XCTAssertTrue(!fileExists || !isDirectory,
                  @"`dealloc` is fail, directory exists but change format to `file`, %@", directoryPath);
}

- (void)testInheritance
{
    Diskcached *baseClass = [Diskcached defaultCached];
    TestDiskcached *inheritedClass = [TestDiskcached defaultCached];

    XCTAssertEqual(baseClass.directoryPath, inheritedClass.directoryPath,
                      @"`inheritance` about default cached is fail, base:%@, inherited:%@",
                      baseClass.directoryPath, inheritedClass.directoryPath);
}

// NSString Category

- (void)testEncodeAndDecode
{
    NSStringEncoding enc = NSUTF8StringEncoding;
    id valid;

    NSString *str = @"あいう";
    NSString *result = [str diskcached_stringByEscapesUsingEncoding:enc];

    valid = @"%E3%81%82%E3%81%84%E3%81%86";
    XCTAssertTrue([result isEqual:valid],
                   @"`encode` is fail, str :%@",
                   str);

    XCTAssertTrue([[result diskcached_stringByEscapesUsingDecoding:enc] isEqual:str],
                  @"`encode` is fail, str :%@",
                  str);



    NSString *path = @"../";
    XCTAssertFalse([[path diskcached_stringByEscapesUsingEncoding:enc] isEqual:path],
                   @"`encode` is fail, path :%@",
                   path);
}

@end
