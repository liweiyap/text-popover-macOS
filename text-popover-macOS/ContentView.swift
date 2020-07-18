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
    
    @State var currentDate: Date = Date()
    let timer = Timer.publish(every: 60*60*24, on: .main, in: .common).autoconnect()
    
    func update(_ randomDatabaseEntry: DatabaseManager.DataModel) -> Void
    {
        Expression = randomDatabaseEntry.Expression
        Explanation = randomDatabaseEntry.Explanation
        Elaboration = randomDatabaseEntry.Elaboration
    }
    
    var body: some View
    {
        HStack
        {
            Spacer()
            
            VStack
            {
                Spacer()
                
                Text(Expression)
                .onAppear
                {
                    let randomDatabaseEntry = self.databaseManagerWrapper.getRandomDatabaseEntry()
                    self.update(randomDatabaseEntry)
                }
                .onReceive(timer)
                {
                    time in
                    
                    var randomDatabaseEntry = self.databaseManagerWrapper.getRandomDatabaseEntry()
                    while (self.Expression == randomDatabaseEntry.Expression)
                    {
                        randomDatabaseEntry = self.databaseManagerWrapper.getRandomDatabaseEntry()
                    }
                    self.update(randomDatabaseEntry)
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
