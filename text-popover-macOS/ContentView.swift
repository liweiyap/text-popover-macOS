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
    
    var body: some View
    {
        Button(action: {
            self.elaborationIsViewed.toggle()
        })
        {
            Image(nsImage: NSImage(named: NSImage.infoName)!
                .resized(to: NSSize(width: SettingsButton.SettingsButtonDimensions,
                                    height: SettingsButton.SettingsButtonDimensions))!)
            .renderingMode(.original)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BackButton: View
{
    @Binding var elaborationIsViewed: Bool
    
    var body: some View
    {
        Button("Back")
        {
            self.elaborationIsViewed.toggle()
        }
    }
}

struct CloseButtonStyle: ButtonStyle
{
    func makeBody(configuration: Self.Configuration) -> some View
    {
        configuration.label
            .frame(width: 12, height: 12)
            .foregroundColor(Color.black)
            .background(Color.sunsetOrange)
            .clipShape(Circle())
    }
}

struct CloseButton: View
{
    var body: some View
    {
        Button(action: {
            NSApp.terminate(self)
        })
        {
            Text("×")
        }
        .buttonStyle(CloseButtonStyle())
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
    
    func showPopoverIfNotAlreadyShown() -> Void
    {
        if !(AppDelegateInstance?.popover.isShown)!
        {
            if let button = AppDelegateInstance?.statusItem.button
            {
                AppDelegateInstance?.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                AppDelegateInstance?.eventMonitor?.start()
            }
        }
    }
    
    @ViewBuilder
    var body: some View
    {
        HStack
        {
            Spacer()
            
            VStack
            {
                HStack
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
                self.showPopoverIfNotAlreadyShown()
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
