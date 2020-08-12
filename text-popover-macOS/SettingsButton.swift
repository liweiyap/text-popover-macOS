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
    @Binding var displayExplanation: Bool
    @Binding var displayElaboration: Bool
    
    var body: some View
    {
        TabView
        {
            IntervalSettingsView()
            .tabItem
            {
                Text("Interval")
            }
            .environmentObject(self.timerWrapper)
            
            AdditionalToggableTextSettingsView(displayExplanation: self.$displayExplanation,
                                               displayElaboration: self.$displayElaboration)
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
    @Binding var displayExplanation: Bool
    @Binding var displayElaboration: Bool
    
    @State var window: NSWindow?
    
    var body: some View
    {
        Button("⚙")
        {
            NSApplication.shared.keyWindow?.close()
            
            let allSettingsView = AllSettingsView(displayExplanation: self.$displayExplanation,
                                                  displayElaboration: self.$displayElaboration)
                .environmentObject(self.timerWrapper)
            
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
//            self.window!.makeKeyAndOrderFront(nil)
            self.window!.orderFront(nil)
            self.window!.isReleasedWhenClosed = false
        }
    }
}
