<img src="text-popover-macOS/Assets.xcassets/popover-appicon-with-text.imageset/popover-appicon-with-text.png">

Text-Popover is a MacOS app that produces pop-ups from the status bar at the top of the screen at user-specified intervals. These pop-ups contain user-specified texts, such as quotes or idioms. Language learners could find this app especially useful, as they could use these pop-ups as virtual placards.

| Light mode             |  Dark mode               |
:-----------------------:|:-------------------------:
![](text-popover-macOS/Assets.xcassets/screenshot-screen-lightmode.png) | ![](text-popover-macOS/Assets.xcassets/screenshot-screen-darkmode.png)

## Usage

### Adjusting the settings

## Installation

### Requirements

* [Xcode](https://apps.apple.com/gb/app/xcode/id497799835?mt=12) _(we used version 12.3)_
* [Carthage](https://github.com/Carthage/Carthage) _(can be downloaded using [Homebrew](https://brew.sh/))_
* Python 3 with [Beautiful Soup](https://pypi.org/project/beautifulsoup4/) _(we used version 4.9.1)_ installed

### Instructions for installation

1. Download the source code by clicking on the green 'Code' button on this website. Alternatively, clone the repository by first navigating to the path where you want to store the local copy and then running the following command in the Terminal:
   ```bash
   git clone https://github.com/liweiyap/text-popover-macOS.git
   ```
2. Install the [SQLite.swift](https://github.com/stephencelis/SQLite.swift) dependency using Carthage.
   * Navigate to the root directory of the repository and run the following command in the Terminal:
     ```bash
     carthage update --platform macOS
     ```
     This will produce a 'Carthage' folder in the root directory of the repository.
   * Navigate to 'Carthage > Checkouts > SQLite.swift' and open the file 'SQLite.xcodeproj' in Xcode.
   * [Set `Build Libraries for Distribution` to `Yes`](https://stackoverflow.com/questions/60162207/module-was-not-compiled-with-library-evolution-support-using-it-means-binary-co) and close the file 'SQLite.xcodeproj'.
   * Return to the root directory of the repository and run the following command in the Terminal:
     ```bash
     carthage build --platform macOS
     ```
   * Now, open the main file 'text-popover-macOS.xcodeproj' in Xcode.
   * In the 'General' settings tab of the 'text-popover-macOS' target, scroll down to the section 'Frameworks, Libraries, and Embedded Content'. Drag and drop the entire 'Carthage/Build/Mac/SQLite.framework' folder into this section.
3. Build and run the app in Xcode by clicking on the triangular icon at the top left corner of the screen.
   * If the following message box appears, click OK.
     
     <img src="text-popover-macOS/Assets.xcassets/screenshot-accessibility-popupmsg.png" width="250"/>
   * You might also need to open 'System Preferences > Security & Privacy > Privacy > Accessibility' and tick the check-box next to the 'Text-Popover' program.

Note: To build the default database with German idioms (_Redewendungen_), we need Python 3 with its library 'Beautiful Soup'. Python 3 is not required for any further databases that the user may wish to add.
