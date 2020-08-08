//
//  SettingsButton.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 30.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI
import Combine

struct IntervalMenuItemButton: View
{
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let window: NSWindow?
    let name: String
    let value: Double
    
    var body: some View
    {
        Button(name)
        {
            self.timer = Timer.publish(every: self.value, on: .main, in: .common).autoconnect()
            self.window!.close()
        }
    }
}

struct IntervalSettingsView: View
{
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let window: NSWindow?
    
    var body: some View
    {
        VStack
        {
            MenuButton("Minuten")
            {
                ForEach(MinutesInterval.allCases, id: \.self)
                {
                    key in

                    IntervalMenuItemButton(timer: self.$timer, window: self.window,
                                           name: key.rawValue, value: key.getInterval())
                }
            }
            .frame(width: 100.0)
            
            MenuButton("Stunden")
            {
                ForEach(HoursIntervalShort.allCases, id: \.self)
                {
                    key in

                    IntervalMenuItemButton(timer: self.$timer, window: self.window,
                                           name: key.rawValue, value: key.getInterval())
                }
                
                Divider()
                
                ForEach(HoursIntervalLong.allCases, id: \.self)
                {
                    key in

                    IntervalMenuItemButton(timer: self.$timer, window: self.window,
                                           name: key.rawValue, value: key.getInterval())
                }
            }
            .frame(width: 100.0)
        }
    }
}

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
