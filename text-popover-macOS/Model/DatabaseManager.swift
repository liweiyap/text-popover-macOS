//
//  DatabaseManager.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 18.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import Foundation
import SQLite
import Combine

final class DatabaseManager: ObservableObject
{
    @Published var database: Database = DatabaseGermanIdiomsImpl(
        URL(fileURLWithPath: #file).deletingLastPathComponent().path +
        "/../../text-popover-macOSDatabaseFiles/german-idioms.db", true)
    
    @Published var toAddNewDatabase: Bool = false
    @Published var toRemoveOldDatabase: Bool = false
    
    let databasesChanged = PassthroughSubject<Void, Never>()
    
    func notifyDatabasesChanged() -> Void
    {
        databasesChanged.send()
    }
    
    enum DatabaseManagerError: Error
    {
        case moreThanOneTableInDBFile
    }
    
    func getRandomDatabaseEntry() -> DataModel
    {
        return database.getRandomDatabaseEntry()
    }
    
    func getDatabaseEntryCount() -> Int
    {
        return database.getDatabaseEntryCount()
    }
    
    func getDatabaseNames() -> [String]
    {
        var databases = [String]()
        
        let fileManager = FileManager.default
        let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(
            at: URL(string: URL(fileURLWithPath: #file).deletingLastPathComponent().path + "/../../text-popover-macOSDatabaseFiles")!,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles)!
        
        while let databaseUrl = enumerator.nextObject() as? URL
        {
            let databaseUrlString = databaseUrl.absoluteString
            if databaseUrlString.hasSuffix("db")  // checks the extension
            {
                do
                {
                    let databaseConnection = try Connection(databaseUrlString)
                    for tableNames in try databaseConnection.prepare(
                        "SELECT name FROM sqlite_master WHERE type='table';")
                    {
                        if tableNames.count > 1
                        {
                            throw DatabaseManagerError.moreThanOneTableInDBFile
                        }
                        
                        if let tableName = tableNames[0]
                        {
                            databases.append(tableName as! String)
                        }
                    }
                }
                catch DatabaseManagerError.moreThanOneTableInDBFile
                {
                    print("DatabaseManager::getDatabaseNames(): Reading of .db files with more than one table is not yet supported. Please check \(databaseUrlString).\n")
                    return databases
                }
                catch
                {
                    print("DatabaseManager::getDatabaseNames():\n", error)
                    return databases
                }
            }
        }
        
        return databases
    }
}
