<img src="text-popover-macOS/Assets.xcassets/popover-appicon-with-text.imageset/popover-appicon-with-text.png">

Text-Popover is a MacOS app that produces pop-ups from the status bar at the top of the screen at user-specified intervals. These pop-ups contain user-specified texts, such as quotes or idioms. Language learners could find this app especially useful, as they could use these pop-ups as virtual placards.

```
brew update
brew install carthage
# cd into path of .xcodeproj
touch Cartfile
open Cartfile -a Xcode
carthage update --platform macOS
[On your application targets’ General settings tab, in the Embedded Binaries section, drag and drop each framework you want to use from the Carthage/Build folder on disk.](https://github.com/Carthage/Carthage#installing-carthage)
https://stackoverflow.com/questions/40743713/command-line-tool-error-xcrun-error-unable-to-find-utility-xcodebuild-n
```
