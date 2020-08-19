//
//  SettingsButton.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 30.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI
import Combine

struct AllSettingsView: View
{
    @EnvironmentObject var timerWrapper: TimerWrapper
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    @EnvironmentObject var intervalMenuButtonNames: IntervalMenuButtonNames
    
    var body: some View
    {
        TabView
        {
            IntervalSettingsView()
            .tabItem
            {
                Text("Interval")
            }
            
            AdditionalToggableTextSettingsView()
            .tabItem
            {
                Text("Additional Texts")
            }
        }
    }
}

struct SettingsButton: View
{
    @EnvironmentObject var timerWrapper: TimerWrapper
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    @EnvironmentObject var intervalMenuButtonNames: IntervalMenuButtonNames
    
    @State var window: NSWindow?
    
    static var SettingsButtonDimensions: Int = 20
    
    // Alternative to `Image(nsImage).scaledToFit()`
    func resize(image: NSImage, width: Int, height: Int) -> NSImage
    {
        let destSize = NSMakeSize(CGFloat(width), CGFloat(height))
        let newImage = NSImage(size: destSize)
        
        newImage.lockFocus()
        image.draw(
            in: NSMakeRect(0, 0, destSize.width, destSize.height),
            from: NSMakeRect(0, 0, image.size.width, image.size.height),
            operation: NSCompositingOperation.sourceOver,
            fraction: CGFloat(1))
        newImage.unlockFocus()
        
        newImage.size = destSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
    
    var body: some View
    {
        Button(action: {
            let allSettingsView = AllSettingsView()
                .environmentObject(self.timerWrapper)
                .environmentObject(self.additionalToggableTextOptions)
                .environmentObject(self.intervalMenuButtonNames)
            
            if self.window != nil
            {
                self.window!.close()
                self.window = nil
            }
            
            self.window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            self.window!.center()
            self.window!.setFrameAutosaveName("Settings")
            self.window!.title = "Settings"
            self.window!.contentView = NSHostingView(rootView: allSettingsView)
            self.window!.orderFrontRegardless()
            self.window!.isReleasedWhenClosed = false
        })
        {
            // For some reason, when `Text("⚙").font(.title)` is used, there is some vspace above the ⚙?
            Image(nsImage: resize(image: NSImage(named: NSImage.advancedName)!,
                                  width: SettingsButton.SettingsButtonDimensions,
                                  height: SettingsButton.SettingsButtonDimensions))
            .renderingMode(.original)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
