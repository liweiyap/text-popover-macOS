//
//  DatabaseManagerWrapper.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 18.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import Foundation
import SQLite

final class DatabaseManagerWrapper: ObservableObject
{
    @Published var databaseManager = DatabaseManagerGermanIdiomsImpl(
        URL(fileURLWithPath: #file).deletingLastPathComponent().path +
        "/../text-popover-macOSUtils/german-idioms.db")
    
    func getRandomDatabaseEntry() -> DataModel
    {
        return databaseManager.getRandomDatabaseEntry()
    }
    
    func getDatabaseNames() -> [String]
    {
        var databases = [String]()
        
        let fileManager = FileManager.default
        let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(
            at: URL(string: URL(fileURLWithPath: #file).deletingLastPathComponent().path + "/../text-popover-macOSUtils")!,
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
                        if let tableName = tableNames[0]
                        {
                            databases.append(tableName as! String)
                        }
                    }
                }
                catch
                {
                    print("DatabaseManagerWrapper::getDatabaseNames():\n", error)
                }
            }
        }
        
        return databases
    }
}
