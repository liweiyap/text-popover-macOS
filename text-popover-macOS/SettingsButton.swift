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
    let window: NSWindow?
    
    @Binding var displayExplanation: Bool
    @Binding var displayElaboration: Bool
    
    var body: some View
    {
        TabView
        {
            IntervalSettingsView(timer: self.$timer, window: window)
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
    
    var body: some View
    {
        Button("⚙")
        {
            NSApplication.shared.keyWindow?.close()
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            
            let allSettingsView = AllSettingsView(timer: self.$timer, window: window,
                                                  displayExplanation: self.$displayExplanation,
                                                  displayElaboration: self.$displayElaboration)
            
            window.center()
            window.setFrameAutosaveName("Settings")
            window.contentView = NSHostingView(rootView: allSettingsView)
//            window.makeKeyAndOrderFront(nil)
            window.orderFront(nil)
            window.isReleasedWhenClosed = false
        }
    }
}
