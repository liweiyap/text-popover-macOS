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
    let databaseManager = DatabaseManager(
        URL(fileURLWithPath: #file).deletingLastPathComponent().path +
        "/../text-popover-macOSUtils/redewendungen.db")
    
    var randomDatabaseEntry: DatabaseManager.DataModel
    
    init()
    {
        randomDatabaseEntry = databaseManager.getRandomDatabaseEntry()
    }
    
    var body: some View
    {
        VStack
        {
            Text(randomDatabaseEntry.Expression)
            Text(randomDatabaseEntry.Explanation)
            Text(randomDatabaseEntry.Elaboration)
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
