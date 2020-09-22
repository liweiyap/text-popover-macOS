//
//  SettingsButton.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 30.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI
import Combine

struct SingleSettingsView<Content:View>: View
{
    var label: String
    var labelWidthProportion: CGFloat
    
    var view: Content
    var viewWidthProportion: CGFloat
    
    init(label: String, view: Content)
    {
        self.label = label
        self.labelWidthProportion = 3.0/8.0
        
        self.view = view
        self.viewWidthProportion = 5.0/8.0
        
        assert(abs(self.labelWidthProportion + self.viewWidthProportion - 1.0) < 1e-3,
               "SingleSettingsView::init(): The sum of both labelWidthProportion and viewWidthProportion must be equal to 1.")
    }
    
    var body: some View
    {
        HStack(alignment: .firstTextBaseline)
        {
            Text("\(label):")
            .frame(width: CGFloat(SettingsButton.SettingsWindowWidth) * labelWidthProportion,
                   alignment: .trailing)
            
            view
            .frame(width: CGFloat(SettingsButton.SettingsWindowWidth) * viewWidthProportion,
                   alignment: .leading)
        }
    }
}

final class BackgroundOptions: ObservableObject
{
    @Published var darkMode: Bool = true
    {
        didSet
        {
            toggleBackgroundColour()
        }
    }
    
    func toggleBackgroundColour() -> Void
    {
        if (self.darkMode)
        {
            AppDelegate.selfInstance?.popover.appearance = NSAppearance(named: .darkAqua)
        }
        else
        {
            AppDelegate.selfInstance?.popover.appearance = NSAppearance(named: .aqua)
        }
    }
}

struct BackgroundSettingsView: View
{
    @EnvironmentObject var backgroundOptions: BackgroundOptions
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Toggle(isOn: $backgroundOptions.darkMode)
            {
                Text("Dark mode")
            }
        }
    }
}

struct AllSettingsView: View
{
    var body: some View
    {
        VStack(alignment: .center)
        {
            SingleSettingsView(label: "Interval", view: IntervalSettingsView())
            Divider()
            SingleSettingsView(label: "Activity on timeout", view: TimeoutActivitySettingsView())
            Divider()
            SingleSettingsView(label: "Additional texts", view: AdditionalToggableTextSettingsView())
            Divider()
            SingleSettingsView(label: "Background", view: BackgroundSettingsView())
        }
    }
}

struct SettingsButton: View
{
    @EnvironmentObject var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    @EnvironmentObject var timeoutActivityOptions: TimeoutActivityOptions
    @EnvironmentObject var backgroundOptions: BackgroundOptions
    @EnvironmentObject var intervalMenuButtonNames: IntervalMenuButtonNames
    
    @State var window: NSWindow?
    
    static var SettingsButtonDimensions: Int = 20
    static var SettingsWindowWidth: Int = 480
    static var SettingsWindowHeight: Int = 300
    
    var body: some View
    {
        Button(action: {
            let allSettingsView = AllSettingsView()
                .environmentObject(self.countdownTimerWrapper)
                .environmentObject(self.additionalToggableTextOptions)
                .environmentObject(self.timeoutActivityOptions)
                .environmentObject(self.backgroundOptions)
                .environmentObject(self.intervalMenuButtonNames)
            
            if self.window != nil
            {
                self.window!.close()
                self.window = nil
            }
            
            self.window = NSWindow(
                contentRect: NSRect(x: 0, y: 0,
                                    width: SettingsButton.SettingsWindowWidth,
                                    height: SettingsButton.SettingsWindowHeight),
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
            /*
             * For some reason, when `Text("⚙").font(.title)` is used, there is some vspace above the ⚙?
             *
             * Use .resized() as an alternative to `Image(nsImage).scaledToFit()`
             */
            Image(nsImage: NSImage(named: NSImage.advancedName)!
                .resized(to: NSSize(width: SettingsButton.SettingsButtonDimensions,
                                    height: SettingsButton.SettingsButtonDimensions))!)
            .renderingMode(.original)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
