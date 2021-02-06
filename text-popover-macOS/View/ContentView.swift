//
//  ContentView.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 13.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI

struct ContentView: View
{
    @State private var Expression: String = ""
    @State private var Explanation: String = ""
    @State private var Elaboration: String = ""
    @State private var elaborationIsViewed: Bool = false
    private let displayTextFontStyle: String = "Papyrus"
    
    @EnvironmentObject private var databaseManager: DatabaseManager
    @EnvironmentObject private var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject private var additionalToggableTextOptions: AdditionalToggableTextOptions
    @EnvironmentObject private var timeoutActivityOptions: TimeoutActivityOptions
    @EnvironmentObject private var backgroundOptions: BackgroundOptions
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    private func update(_ randomDatabaseEntry: DataModel) -> Void
    {
        Expression = randomDatabaseEntry.Expression
        Explanation = randomDatabaseEntry.Explanation
        Elaboration = randomDatabaseEntry.Elaboration
    }
    
    private func update() -> Void
    {
        var randomDatabaseEntry = databaseManager.getRandomDatabaseEntry()
        while (Expression == randomDatabaseEntry.Expression)
        {
            randomDatabaseEntry = databaseManager.getRandomDatabaseEntry()
        }
        update(randomDatabaseEntry)
    }
    
    private func togglePopover() -> Void
    {
        if ( timeoutActivityOptions.showPopoverOnTimeout && (!(AppDelegate.selfInstance?.popover.isShown)!) )
        {
            if let button = AppDelegate.selfInstance?.statusItem.button
            {
                AppDelegate.selfInstance?.popover.show(relativeTo: button.bounds, of: button,
                                                       preferredEdge: NSRectEdge.minY)
                AppDelegate.selfInstance?.eventMonitor?.start()
            }
        }
    }
    
    private func playSound() -> Void
    {
        timeoutActivityOptions.soundOnTimeout?.play()
    }
    
    private func toggleBackgroundColour() -> Void
    {
        backgroundOptions.darkMode = (colorScheme == .dark)
    }
    
    @ViewBuilder
    var body: some View
    {
        HStack
        {
            Spacer()
            
            VStack
            {
                ContentViewToolbar(elaborationIsViewed: $elaborationIsViewed)
                .font(.custom(displayTextFontStyle, size: 15))
                
                Spacer()
                
                if elaborationIsViewed
                {
                    Text(Elaboration)
                    .font(.custom(displayTextFontStyle, size: 10))
                }
                else
                {
                    Text(Expression)
                    .font(.custom(displayTextFontStyle, size: 15))
                    
                    Spacer()
                    
                    if additionalToggableTextOptions.displayExplanation
                    {
                        Text(Explanation)
                        .font(.custom(displayTextFontStyle, size: 12))
                    }
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .onAppear
        {
            toggleBackgroundColour()
            update()
        }
        .onReceive(countdownTimerWrapper.timer)
        {
            time in
            
            countdownTimerWrapper.timeRemaining -= 1
            
            if countdownTimerWrapper.timeRemaining == 0
            {
                update()
                togglePopover()
                playSound()
                countdownTimerWrapper.timeRemaining = countdownTimerWrapper.interval
            }
        }
        .onReceive(databaseManager.databasesChanged)
        {
            _ in
            
            update()
        }
    }  // body
}
