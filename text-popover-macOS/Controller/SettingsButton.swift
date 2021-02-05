//
//  SettingsButton.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 30.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI

struct SingleGeneralSettingView<Content:View>: View
{
    var label: String
    var labelWidthProportion: CGFloat
    
    var view: Content
    var viewWidthProportion: CGFloat
    
    init(label: String, view: Content)
    {
        self.label = label
        labelWidthProportion = 3.0/8.0
        
        self.view = view
        viewWidthProportion = 5.0/8.0
        
        assert(abs(labelWidthProportion + viewWidthProportion - 1.0) < 1e-3,
               "SingleGeneralSettingView::init(): The sum of both labelWidthProportion and viewWidthProportion must be equal to 1.")
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

struct GeneralSettingsView: View
{
    var body: some View
    {
        VStack(alignment: .center)
        {
            SingleGeneralSettingView(label: "Interval", view: IntervalSettingsView())
            Divider()
            SingleGeneralSettingView(label: "Activity on timeout", view: TimeoutActivitySettingsView())
            Divider()
            SingleGeneralSettingView(label: "Additional texts", view: AdditionalToggableTextSettingsView())
            Divider()
            SingleGeneralSettingView(label: "Background", view: BackgroundSettingsView())
            Spacer()
        }
    }
}

struct AuthorView: View
{
    @EnvironmentObject var backgroundOptions: BackgroundOptions
    
    var body: some View
    {
        VStack
        {
            if backgroundOptions.darkMode
            {
                Image("logo-grey-background-black")
                .resizable()
                .scaledToFit()
            }
            else
            {
                Image("logo-black-background-grey")
                .resizable()
                .scaledToFit()
            }
            
            Text("Made with ❤️. Copyright © 2021 Li-Wei Yap")
            
            Spacer()
        }
    }
}

struct AllSettingsView: View
{
    @State var defaultViewIdx = 1
    
    var body: some View
    {
        TabView(selection: $defaultViewIdx)
        {
            AuthorView()
            .tabItem{
                Text("Author")
            }
            .tag(0)
            
            GeneralSettingsView()
            .tabItem
            {
                Text("General")
            }
            .tag(1)
            
            DatabaseSelectionView()
            .tabItem
            {
                Text("Databases")
            }
            .tag(2)
        }
    }
}

struct SettingsButton: View
{
    @EnvironmentObject var databaseManager: DatabaseManager
    @EnvironmentObject var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    @EnvironmentObject var timeoutActivityOptions: TimeoutActivityOptions
    @EnvironmentObject var backgroundOptions: BackgroundOptions
    @EnvironmentObject var intervalMenuButtonNames: IntervalMenuButtonNames
    
    @State var window: NSWindow?
    
    static let SettingsButtonDimensions: Int = 20
    static let SettingsWindowWidth: Int = 480
    static let SettingsWindowHeight: Int = 330
    
    var body: some View
    {
        Button(action: {
            let allSettingsView = AllSettingsView()
                .environmentObject(databaseManager)
                .environmentObject(countdownTimerWrapper)
                .environmentObject(additionalToggableTextOptions)
                .environmentObject(timeoutActivityOptions)
                .environmentObject(backgroundOptions)
                .environmentObject(intervalMenuButtonNames)
            
            if window != nil
            {
                window!.close()
                window = nil
            }
            
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0,
                                    width: SettingsButton.SettingsWindowWidth,
                                    height: SettingsButton.SettingsWindowHeight),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window!.center()
            window!.setFrameAutosaveName("Settings")
            window!.title = "Settings"
            window!.contentView = NSHostingView(rootView: allSettingsView)
            window!.orderFrontRegardless()
            window!.isReleasedWhenClosed = false
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
