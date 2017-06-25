# RASErrorHandling

Demo project to present [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) capabilities on error handling.

# Topic

The project presents error mapping from low level network related errors, through parsing errors ending on high level user oriented error types.

Project utilizes strongly typed errors in ReactiveSwift to present the concept and show framework's capabilities.

# Setup

0. You will need `carthage` in version 0.23.0 or higher, to install run:
```
brew install carthage
```
1. Clone the project and navigation to project's root dir
2. Run:
```
carthage bootstrap --platform iOS --cache-builds
```

3. Compile & run the project

# Project organization

Project consists of:
* Main.storyboard
* `ViewController.swift` - main and only view controller
* Network related files: `HTTPResponse`, `HTTPTransaction`, `HTTPError`
* JSON decoding: `JSONFormat` & `JSONDecodingError`
* `URLRequest` extension

Main logic of the app (and the main concept) can be found in `ViewController`.

# Other

Author: [Radosław Szeja](https://github.com/rad3ks)

License: [MIT](https://github.com/rad3ks/RASErrorHandling/LICENSE)

Special thanks to [netguru.co](https://netguru.co)
