//
//  ContentView.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 13.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI

struct ElaborationButton: View
{
    @Binding var elaborationIsViewed: Bool
    
    static var ElaborationButtonDimensions: CGFloat = 20.0
    
    var body: some View
    {
        Button(action: {
            self.elaborationIsViewed.toggle()
        })
        {
            Image(nsImage: NSImage(named: NSImage.infoName)!
                .resized(to: NSSize(width: ElaborationButton.ElaborationButtonDimensions,
                                    height: ElaborationButton.ElaborationButtonDimensions))!)
            .renderingMode(.original)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BackButtonStyle: ButtonStyle
{
    static var BackButtonDimensions: CGFloat = 16.0
    
    func makeBody(configuration: Self.Configuration) -> some View
    {
        configuration.label
            .frame(width: BackButtonStyle.BackButtonDimensions,
                   height: BackButtonStyle.BackButtonDimensions)
            .background(configuration.isPressed ? Color.blue : Color(NSColor.controlColor))
            .clipShape(Circle())
    }
}

struct BackButton: View
{
    @Binding var elaborationIsViewed: Bool
    
    var body: some View
    {
        Button(action: {
            self.elaborationIsViewed.toggle()
        })
        {
            Image(nsImage: NSImage(named: NSImage.leftFacingTriangleTemplateName)!
                .resized(to: NSSize(width: BackButtonStyle.BackButtonDimensions / 2,
                                    height: BackButtonStyle.BackButtonDimensions / 2))!)
            .renderingMode(.original)
        }
        .buttonStyle(BackButtonStyle())
    }
}

struct CloseButtonStyle: ButtonStyle
{
    @Binding var isHovering: Bool
    
    static var CloseButtonDimensions: CGFloat = 12.0
    static var CloseButtonColour = NSColor.sunsetOrange
    
    func makeBody(configuration: Self.Configuration) -> some View
    {
        ZStack
        {
            configuration.label
                .frame(width: CloseButtonStyle.CloseButtonDimensions,
                       height: CloseButtonStyle.CloseButtonDimensions)
                .background(Color(CloseButtonStyle.CloseButtonColour))
                .clipShape(Circle())
        }
        .onHover
        {
            hover in

            self.isHovering = hover
        }
        .overlay(HStack{
            if self.isHovering
            {
                Image(nsImage: NSImage(named: NSImage.stopProgressTemplateName)!
                    .resized(to: NSSize(width: CloseButtonStyle.CloseButtonDimensions / 2,
                                        height: CloseButtonStyle.CloseButtonDimensions / 2))!)
            }
        })
    }
}

struct CloseButton: View
{
    @State var isHovering: Bool = false
    
    var body: some View
    {
        Button(action: {
            NSApp.terminate(self)
        })
        {
            /*
             * For some reason, when `Text("×")` is used, there is some vspace above the ×?
             */
            Image(nsImage: NSImage(named: NSImage.stopProgressTemplateName)!
                .tint(colour: CloseButtonStyle.CloseButtonColour)
                .resized(to: NSSize(width: CloseButtonStyle.CloseButtonDimensions / 2,
                                    height: CloseButtonStyle.CloseButtonDimensions / 2))!)
        }
        .buttonStyle(CloseButtonStyle(isHovering: $isHovering))
    }
}

struct ContentView: View
{
    @ObservedObject var databaseManagerWrapper = DatabaseManagerWrapper()
    @State var Expression: String = ""
    @State var Explanation: String = ""
    @State var Elaboration: String = ""
    @State var elaborationIsViewed: Bool = false
    
    @EnvironmentObject var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    @EnvironmentObject var timeoutActivityOptions: TimeoutActivityOptions
    let intervalMenuButtonNames = IntervalMenuButtonNames()
    
    var AppDelegateInstance = AppDelegate.selfInstance
    
    func update(_ randomDatabaseEntry: DatabaseManager.DataModel) -> Void
    {
        Expression = randomDatabaseEntry.Expression
        Explanation = randomDatabaseEntry.Explanation
        Elaboration = randomDatabaseEntry.Elaboration
    }
    
    func update() -> Void
    {
        var randomDatabaseEntry = databaseManagerWrapper.getRandomDatabaseEntry()
        while (Expression == randomDatabaseEntry.Expression)
        {
            randomDatabaseEntry = databaseManagerWrapper.getRandomDatabaseEntry()
        }
        update(randomDatabaseEntry)
    }
    
    func getTimeRemaining() -> CountdownTimerWrapper.Time
    {
        return countdownTimerWrapper.getTimeRemaining()
    }
    
    func togglePopover() -> Void
    {
        if ( self.timeoutActivityOptions.showPopoverOnTimeout && (!(AppDelegateInstance?.popover.isShown)!) )
        {
            if let button = AppDelegateInstance?.statusItem.button
            {
                AppDelegateInstance?.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                AppDelegateInstance?.eventMonitor?.start()
            }
        }
    }
    
    func playSound() -> Void
    {
        self.timeoutActivityOptions.soundOnTimeout?.play()
    }
    
    @ViewBuilder
    var body: some View
    {
        HStack
        {
            Spacer()
            
            VStack
            {
                HStack(alignment: .center)
                {
                    /*
                     * Manually adjust spacing, because, for some reason,
                     * ElaborationButton by default lies more rightward than BackButton.
                     */
                    HStack(spacing: elaborationIsViewed ? 6 : 4)
                    {
                        CloseButton()
                        
                        if additionalToggableTextOptions.displayElaboration
                        {
                            if elaborationIsViewed
                            {
                                BackButton(elaborationIsViewed: self.$elaborationIsViewed)
                            }
                            else
                            {
                                ElaborationButton(elaborationIsViewed: self.$elaborationIsViewed)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Text("\(String(format:"%02d",getTimeRemaining().hours)):\(String(format:"%02d",getTimeRemaining().minutes))")

                    SettingsButton()
                    .environmentObject(self.intervalMenuButtonNames)
                }  // Inner HStack
                
                Spacer()
                
                if elaborationIsViewed
                {
                    Text(Elaboration)
                }
                else
                {
                    Text(Expression)
                    
                    Spacer()
                    
                    if additionalToggableTextOptions.displayExplanation
                    {
                        Text(Explanation)
                    }
                }
                
                Spacer()
            }  // VStack
            
            Spacer()
        }  // Outer HStack
        .onAppear
        {
            self.update()
        }
        .onReceive(self.countdownTimerWrapper.timer)
        {
            time in
            
            self.countdownTimerWrapper.timeRemaining -= 1
            
            if self.countdownTimerWrapper.timeRemaining == 0
            {
                self.update()
                self.togglePopover()
                self.playSound()
                self.countdownTimerWrapper.timeRemaining = self.countdownTimerWrapper.interval
            }
        }
    }  // body
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
