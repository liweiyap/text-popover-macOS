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
    
    let timerWrapper = TimerWrapper()
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    
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
                    .environmentObject(timerWrapper)
                    .environmentObject(additionalToggableTextOptions)
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
                    
                    self.timerWrapper.counter += 1
                    
                    if self.timerWrapper.counter == self.timerWrapper.interval
                    {
                        self.update()
                        self.timerWrapper.counter = 0
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
