Mumble for iOS
==============

This repository contains a Swift 6 implementation of the Mumble client. All legacy
Objective‑C code has been removed in favour of modern Swift. The application uses
SwiftUI and targets iOS 16 and newer.

Visit our website at <https://mumble.info/>

Building
========

Xcode 15 or later with the iOS 17 SDK is required. The project uses the Swift
Package Manager and consists of a small demo app and a reusable `MumbleCore`
library.

Fetch the repository and build using `swift build`:

```bash
$ git clone https://github.com/0n1cO3/mumble-iphoneos.git
$ cd mumble-iphoneos
$ swift build -c release
```

Unit tests reside in `MumbleApp/Tests` and can be run with `swift test`.
