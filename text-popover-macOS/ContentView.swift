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
    @State var Expression: String = ""
    @State var Explanation: String = ""
    @State var Elaboration: String = ""
    @State var elaborationIsViewed: Bool = false
    
    @EnvironmentObject var databaseManagerWrapper: DatabaseManagerWrapper
    @EnvironmentObject var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    @EnvironmentObject var timeoutActivityOptions: TimeoutActivityOptions
    @EnvironmentObject var backgroundOptions: BackgroundOptions
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    func update(_ randomDatabaseEntry: DataModel) -> Void
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
    
    func togglePopover() -> Void
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
    
    func playSound() -> Void
    {
        timeoutActivityOptions.soundOnTimeout?.play()
    }
    
    func toggleBackgroundColour() -> Void
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
    }  // body
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
