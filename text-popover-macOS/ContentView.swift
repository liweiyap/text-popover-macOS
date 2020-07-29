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
    
    @State var timer = Timer.publish(every: TimeInterval(24.hours), on: .main, in: .common).autoconnect()
    
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

                    MenuButton(">")
                    {
                        Button("5 Sekunden", action: {
                            self.timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
                        })
                        
                        Button("24 Stunden", action: {
                            self.timer = Timer.publish(every: TimeInterval(24.hours), on: .main, in: .common).autoconnect()
                        })
                    }
                    .frame(width: 10.0)
                    .menuButtonStyle(BorderlessButtonMenuButtonStyle())
                }
                
                Spacer()
                
                Text(Expression)
                .onAppear
                {
                    self.update()
                }
                .onReceive(timer)
                {
                    time in
                    
                    self.update()
                }
                
                Spacer()
                
                Text(Explanation)
                
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
