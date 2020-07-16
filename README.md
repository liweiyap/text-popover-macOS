# information-popover-macOS

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
