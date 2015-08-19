# Cube

<!-- [![Version](https://img.shields.io/cocoapods/v/Cube.svg?style=flat)](http://cocoadocs.org/docsets/Cube)
[![License](https://img.shields.io/cocoapods/l/Cube.svg?style=flat)](http://cocoadocs.org/docsets/Cube)
[![Platform](https://img.shields.io/cocoapods/p/Cube.svg?style=flat)](http://cocoadocs.org/docsets/Cube)
[![Build Status](https://img.shields.io/circleci/project/contentful-labs/Cube.svg?style=flat)](https://circleci.com/gh/contentful-labs/Cube)
[![Coverage Status](https://img.shields.io/coveralls/contentful-labs/Cube.svg)](https://coveralls.io/r/contentful-labs/Cube?branch=master) -->

An incomplete [commercetools][6] API client written in Swift.

## Usage

Simply install it via [CocoaPods][4]:

```ruby
use_frameworks!

pod 'Cube'
```

Note: make sure you use version [0.38.2][5] or newer. Cube is written in Swift 2.0,
so it requires Xcode 7.0 or newer as well.

## Import Script

There's [a script](blob/master/Scripts/Sync.swift) which allows importing product data from [commercetools][6] to [Contentful][7], mostly to facilitate linking between entities from the two systems. The script doesn't do a synchronisation, each product is only imported once, you need to manually delete an entry from your Contentful space to have it be reimported.

You need to specify your credentials to both services in environment variables:

- `CONTENTFUL_MANAGEMENT_API_ACCESS_TOKEN`: access token for the Contentful management API
- `SPHERE_IO_CLIENT_ID`: OAuth client ID for commercetools
- `SPHERE_IO_CLIENT_SECRET`: OAuth client secret for commercetools

You can tailor it to your needs by changing the following:

- At the top of the script, you can change the space identifier, etc.
- The mapping is defined in line 60 of the script, you can decide there which product attribute corresponds to which field of your Contentful content type. Most important is the `ContentfulSphereIOFieldId`, because that field is used to make sure entries are not imported twice.

The script requires [cato][8] to run, please install it using:

```bash
$ gem install cocoapods cocoapods-rome
$ brew tap neonichu/formulae
$ brew install cato
```

### Beta Notes

Since Swift 2 is currently in beta, you will need to manually perform the following steps:

1. Go to `~/.📦/Sync`
2. Change the "Podfile" to

```ruby
platform :osx, '10.10'
plugin 'cocoapods-rome'
use_frameworks!
pod "Chores", :git => 'https://github.com/neonichu/Chores.git', :branch => 'swift-2.0'
pod "ContentfulManagementAPI"

pod "Cube", :git => 'https://github.com/contentful-labs/Cube.git', :branch => 'swift-2.0'
pod 'Alamofire', :git => 'https://github.com/neonichu/Alamofire.git', :branch => 'swift-2.0'
pod 'Result', '>= 0.6-beta.1'
```
3. Run `pod install --no-integrate`

This will make sure that Swift 2 compatible versions of the dependencies are used.

## License

Copyright (c) 2015 Contentful GmbH. See [LICENSE](LICENSE) for further details.


[4]: http://cocoapods.org
[5]: http://blog.cocoapods.org/CocoaPods-0.37/
[6]: http://www.commercetools.com
[7]: https://www.contentful.com
[8]: https://github.com/neonichu/cato
