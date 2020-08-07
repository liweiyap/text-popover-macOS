//
//  SettingsButton.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 30.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI
import Combine

struct TimeMenuItemButton: View
{
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let myWindow: NSWindow?
    let name: String
    let value: Double
    
    var body: some View
    {
        Button(name)
        {
            self.timer = Timer.publish(every: self.value, on: .main, in: .common).autoconnect()
            self.myWindow!.close()
        }
    }
}

struct IntervalSettingsView: View
{
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let myWindow: NSWindow?
    
    var body: some View
    {
        MenuButton("Minuten")
        {
            TimeMenuItemButton(timer: self.$timer, myWindow: myWindow,
                               name: "5 Minuten", value: 5.0)
            
            Divider()
            
            TimeMenuItemButton(timer: self.$timer, myWindow: myWindow,
                               name: "10 Minuten", value: 10.0 * Double(Int.secondsPerMinute))
            
            TimeMenuItemButton(timer: self.$timer, myWindow: myWindow,
                               name: "15 Minuten", value: 15.0 * Double(Int.secondsPerMinute))
            
            Divider()
            
            TimeMenuItemButton(timer: self.$timer, myWindow: myWindow,
                               name: "20 Minuten", value: 20.0 * Double(Int.secondsPerMinute))
            
            TimeMenuItemButton(timer: self.$timer, myWindow: myWindow,
                               name: "25 Minuten", value: 25.0 * Double(Int.secondsPerMinute))
            
            Divider()
            
            TimeMenuItemButton(timer: self.$timer, myWindow: myWindow,
                               name: "30 Minuten", value: 30.0 * Double(Int.secondsPerMinute))
            
            TimeMenuItemButton(timer: self.$timer, myWindow: myWindow,
                               name: "35 Minuten", value: 35.0 * Double(Int.secondsPerMinute))
        }
        .frame(width: 100.0)
    }
}

struct AllSettingsView: View
{
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let myWindow: NSWindow?
    
    var body: some View
    {
        TabView
        {
            IntervalSettingsView(timer: self.$timer, myWindow: myWindow)
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
            window.contentView = NSHostingView(rootView: AllSettingsView(timer: self.$timer, myWindow: window))
//            window.makeKeyAndOrderFront(nil)
            window.orderFront(nil)
            window.isReleasedWhenClosed = false
        }
    }
}
