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

- (void)testCleanDiskWhenDealloc
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
                  @"`dealloc` is fail, directory exists and change format to `file`, %@", directoryPath);
}

- (void)testNotCleanDiskWhenDealloc
{
    NSString *str = @"test";
    NSString *key = @"key";
    NSString *directoryPath;

    Diskcached *cached = [[Diskcached alloc] initAtPath:@"test" inUserDomainDirectory:NSCachesDirectory];
    cached.cleanDiskWhenDealloc = NO;
    directoryPath = cached.directoryPath;

    [cached setObject:str forKey:key];

    XCTAssertNotNil([cached objectForKey:key],
                    @"Diskcached doesnt have an object");
    cached = nil;

    // validate to have files in directoy
    id contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
    XCTAssertNotNil(contents,
                    @"`dealloc` is fail, files dont exists, %@", directoryPath);

    // validate to exist directoy
    BOOL isDirectory = NO;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDirectory];

    XCTAssertTrue(fileExists,
                  @"`dealloc` is fail, directory dont exists, %@", directoryPath);
    XCTAssertTrue(fileExists && isDirectory,
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

- (void)testAsync
{
    Diskcached *cached = [[Diskcached alloc] init];
    [cached setObject:@"test" forKey:@"key"];
    [cached setObject:@"test2" forKey:@"key"];

    id result = [cached objectForKey:@"key"];
    id valid  = @"test2";

    XCTAssertTrue([result isEqualToString:valid],
                   @"`set on async` is fail, result is %@", result);
}

// NSString Category

- (void)testEncodeAndDecode
{
    NSStringEncoding enc = NSUTF8StringEncoding;
    NSString *str;
    id valid;

    str     = @"あいう";
    valid   = @"%E3%81%82%E3%81%84%E3%81%86";

    NSString *result = [str diskcached_stringByEscapesUsingEncoding:enc];
    XCTAssertTrue([result isEqual:valid],
                   @"`encode` is fail, str :%@",
                   str);
    XCTAssertTrue([[result diskcached_stringByEscapesUsingDecoding:enc] isEqual:str],
                  @"`decode` is fail, str :%@",
                  str);



    str     = @"../";
    valid   = @"..%2F";
    XCTAssertTrue([[str diskcached_stringByEscapesUsingEncoding:enc] isEqual:valid],
                  @"`encode` is fail, str :%@",
                  str);
}

@end
