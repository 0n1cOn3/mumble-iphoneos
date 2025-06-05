Mumble for iOS (iPhone, iPod touch and iPad)
============================================

**Note:** This repo and the app for iOS is WIP.
If you are interested in taking over development of the app, write a comment in [#129](https://github.com/mumble-voip/mumble-iphoneos/issues/129).

This is the source code of Mumble (a voice chat application) for iOS-based devices.

The [desktop version](https://github.com/mumble-voip/mumble) of Mumble runs on Windows, Mac OS X, Linux
and various other Unix-like systems. 

Visit our website at:
<https://mumble.info/>

Building it
===========

To build this you need Xcode 13 and the latest iOS SDK from Apple.

The easiest way to get a working source tree is to check out
the mumble-iphoneos repository recursively (his will recursively
fetch all submodules), because there are quite a few submodules.

To fetch the repository:

    $ git clone --recursive http://github.com/0n1cO3/mumble-iphoneos.git

Once this is done, you should be able to open up the Xcode
project file for Mumble (Mumble.xcodeproj) in the root of
the source tree and hit Cmd-B to build!


Extra tips for advanced users
=============================

When launching Mumble.xcodeproj for the first time, you're recommended to
remove all schemes but the Mumble one. Xcode will automatically populate
it with the schemes of all .xcodeprojs in the workspace.

Schemes can be configured using the dropdown box right of the start and stop
buttons in the default Xcode 13 UI.

We also recommend you to edit the default scheme for the Mumble target
and change the Archive configuration to BetaDist, and the Test configuration
to Release (debug builds pretty slow for devices, but for the Simulator, they're
OK!)

Cross-platform building with xtool
---------------------------------

Mumble can also be built using [xtool](https://github.com/segiddins/xtool). Make
sure `xtool` is installed and available in your `PATH`.

The provided `Makefile` exposes convenient targets for building or running the
app using xtool:

    make build  # builds Mumble for iOS 9-18
    make run    # launches the app in the simulator

Other targets such as `make pack` or `make install` package the app as an `.ipa`
and install it on a connected device.

Running the unit tests
----------------------

The included test suite uses the XCTest framework. To execute the tests,
open `Mumble.xcodeproj` and run the **Test** action (⌘U) or invoke
`xcodebuild test`. The resulting `MumbleTests.xctest` bundle is run via
`xcrun xctest`.
