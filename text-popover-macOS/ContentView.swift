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
    var body: some View
    {
        Button(action: {
            
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

struct ContentView: View
{
    @ObservedObject var databaseManagerWrapper = DatabaseManagerWrapper()
    @State var Expression: String = ""
    @State var Explanation: String = ""
    @State var Elaboration: String = ""
    
    @EnvironmentObject var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    let intervalMenuButtonNames = IntervalMenuButtonNames()
    
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
                    Button("Quit")
                    {
                        NSApp.terminate(self)
                    }
                    
                    if additionalToggableTextOptions.displayElaboration
                    {
                        ElaborationButton()
                    }
                    
                    Spacer()
                    
                    Text("\(String(format:"%02d",getTimeRemaining().hours)):\(String(format:"%02d",getTimeRemaining().minutes))")

                    SettingsButton()
                    .environmentObject(self.intervalMenuButtonNames)
                }
                
                Spacer()
                
                Text(Expression)
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
                        self.countdownTimerWrapper.timeRemaining = self.countdownTimerWrapper.interval
                    }
                }
                
                Spacer()
                
                if additionalToggableTextOptions.displayExplanation
                {
                    Text(Explanation)
                }
                
                Spacer()
            }
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
