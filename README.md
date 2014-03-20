Diskcached [![Build Status](https://travis-ci.org/hirohisa/Diskcached.png?branch=master)](https://travis-ci.org/hirohisa/Diskcached)
==================

Diskcached is simple disk cache for iOS.

- Simple methods
- Writing asynchronously to disk
- Controlling to clean disk when it called `dealloc`

Installation
----------

There are two ways to use this in your project:

- Copy the Diskcached class files into your project

- Install with CocoaPods to write Podfile
```ruby
platform :ios
pod 'Diskcached', :git => 'https://github.com/hirohisa/Diskcached.git'
```

Example
----------

```objc


Diskcached *cached = [[Diskcached alloc] init];
[cached setObject:object forKey:@"key"];

id result = [cached objectForKey:@"key"];

```

## License

Diskcached is available under the MIT license.
