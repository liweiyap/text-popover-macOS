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
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @Binding var displayExplanation: Bool
    @Binding var displayElaboration: Bool
    
    var body: some View
    {
        TabView
        {
            IntervalSettingsView(timer: self.$timer)
            .tabItem
            {
                Text("Interval")
            }
            
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
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @Binding var displayExplanation: Bool
    @Binding var displayElaboration: Bool
    
    @State var window: NSWindow?
    
    var body: some View
    {
        Button("⚙")
        {
            NSApplication.shared.keyWindow?.close()
            
            let allSettingsView = AllSettingsView(timer: self.$timer,
                                                  displayExplanation: self.$displayExplanation,
                                                  displayElaboration: self.$displayElaboration)
            
            if let window = self.window
            {
                window.close()
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
