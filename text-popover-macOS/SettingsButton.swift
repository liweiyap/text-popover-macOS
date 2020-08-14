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
    
    var body: some View
    {
        Button("⚙")
        {
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
        }
    }
}
