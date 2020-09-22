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
    @ObservedObject var databaseManagerWrapper = DatabaseManagerWrapper()
    @State var Expression: String = ""
    @State var Explanation: String = ""
    @State var Elaboration: String = ""
    @State var elaborationIsViewed: Bool = false
    
    @EnvironmentObject var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    @EnvironmentObject var timeoutActivityOptions: TimeoutActivityOptions
    @EnvironmentObject var backgroundOptions: BackgroundOptions
    
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
    
    func togglePopover() -> Void
    {
        if ( self.timeoutActivityOptions.showPopoverOnTimeout && (!(AppDelegateInstance?.popover.isShown)!) )
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
