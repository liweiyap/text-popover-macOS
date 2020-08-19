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
    
    @EnvironmentObject var timerWrapper: TimerWrapper
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
    
    func getTimeRemaining() -> TimerWrapper.Time
    {
        return timerWrapper.getTimeRemaining()
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
                    
                    Spacer()

                    SettingsButton()
                    .environmentObject(self.intervalMenuButtonNames)
                }
                
                Spacer()
                
                Text(Expression)
                .onAppear
                {
                    self.update()
                }
                .onReceive(self.timerWrapper.timer)
                {
                    time in
                    
                    self.timerWrapper.timeRemaining -= 1
                    
                    if self.timerWrapper.timeRemaining == 0
                    {
                        self.update()
                        self.timerWrapper.timeRemaining = self.timerWrapper.interval
                    }
                }
                
                Spacer()
                
                if additionalToggableTextOptions.displayExplanation
                {
                    Text(Explanation)
                }
                
                Spacer()
                
                Text("Nächste Redewendung in: \(String(format:"%02d",getTimeRemaining().hours)):\(String(format:"%02d",getTimeRemaining().minutes))")
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
