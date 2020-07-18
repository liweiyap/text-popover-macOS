//
//  DatabaseManagerWrapper.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 18.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import Foundation

final class DatabaseManagerWrapper: ObservableObject
{
    @Published var databaseManager = DatabaseManager(
        URL(fileURLWithPath: #file).deletingLastPathComponent().path +
        "/../text-popover-macOSUtils/redewendungen.db")
    
    func getRandomDatabaseEntry() -> DatabaseManager.DataModel
    {
        return databaseManager.getRandomDatabaseEntry()
    }
}
