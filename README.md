# CMDataStorage

[![Build Status](https://secure.travis-ci.org/mureev/CMDataStorage.png?branch=master)](http://travis-ci.org/mureev/CMDataStorage)
[![CocoaPods](https://cocoapod-badges.herokuapp.com/v/CMDataStorage/badge.png)](http://cocoapods.org/?q=name%3ACMDataStorage%2A)
[![CocoaPods](https://cocoapod-badges.herokuapp.com/p/CMDataStorage/badge.png)](http://cocoapods.org/?q=name%3ACMDataStorage%2A)
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

Simple and powerful API to work with NSData in IOS Cache, Documents and Temp folder.

## Features

- Extremely simple implementation and powerful API
- Separated GCD queues
- Callbacks based on blocks
- Safe file naming using MD5
- Using modern NSURL iOS API for file paths
- 100% bugs free. (Used in many projects)

## Example Usage

### Async save NSData in iOS Documents folder

```objective-c
NSString *uniqueKey = @"unique name";
[CMDataStorage.sharedDocumentsStorage storeData:data key:uniqueKey block:^(BOOL succeeds) {
    //
}];
```

### Async save NSData in iOS Cache folder

```objective-c
NSString *uniqueKey = @"unique name";
[CMDataStorage.sharedCacheStorage storeData:data key:uniqueKey block:^(BOOL succeeds) {
    //
}];
```

### Async read NSData from iOS Cache folder

```objective-c
NSString *uniqueKey = @"unique name";
[CMDataStorage.sharedCacheStorage dataForKey:uniqueKey block:^(NSData *data) {
    //
}];
```

### Sync read NSData from iOS Documents folder

```objective-c
NSString *uniqueKey = @"unique name";
NSData *data = [CMDataStorage.sharedDocumentsStorage dataForKey:uniqueKey];
```

## License

CMDataStorage is available under the MIT license. See the LICENSE file for more info.
