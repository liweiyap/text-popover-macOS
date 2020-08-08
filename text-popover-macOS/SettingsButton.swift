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
    
    var body: some View
    {
        TabView
        {
            IntervalSettingsView(timer: self.$timer, window: window)
            .tabItem
            {
                Text("Intervall")
            }
        }
    }
}

struct SettingsButton: View
{
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
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
            window.center()
            window.setFrameAutosaveName("Settings")
            window.contentView = NSHostingView(rootView: AllSettingsView(timer: self.$timer, window: window))
//            window.makeKeyAndOrderFront(nil)
            window.orderFront(nil)
            window.isReleasedWhenClosed = false
        }
    }
}
