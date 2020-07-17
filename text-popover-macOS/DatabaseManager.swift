//
//  DatabaseManager.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 15.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import Foundation
import SQLite

class DatabaseManager
{
    var database_connection: Connection!
    let database_table = Table("Redewendungen")
    let expression = Expression<String>("Expression")
    let explanation = Expression<String>("Explanation")
    let elaboration = Expression<String>("Elaboration")
    var database_entries: AnySequence<Row>!
    
    struct DataModel: Hashable
    {
        let Expression: String
        let Explanation: String
        let Elaboration: String
    }

    init(_ database_path: String)
    {
        createDatabase(database_path)
        connectDatabase(database_path)
    }
    
    func createDatabase(_ database_path: String) -> Void
    {
        let fileUrl = URL(fileURLWithPath: #file)
        let dirUrl = fileUrl.deletingLastPathComponent()
        let python_script_path = dirUrl.path + "/../text-popover-macOSUtils/create_table.py"
        
        /*
         * Using Process() to find `which python3` returns only:
         * `/Applications/Xcode.app/Contents/Developer/usr/bin/python3`
         * But modules like Beautiful Soup might be installed in other versions of Python located elsewhere
         */
        let python_env_launch_path = "/Users/leewayleaf/opt/anaconda3/bin/python3"
        
        let process = Process()
        process.arguments = [python_script_path, database_path]
        process.executableURL = URL(fileURLWithPath: python_env_launch_path)
        
        do
        {
            try process.run()
        }
        catch
        {
            print("createDatabase():\n", error)
        }
    }
    
    func connectDatabase(_ database_path: String) -> Void
    {
        do
        {
            let database_connection = try Connection(database_path)
            self.database_connection = database_connection
            
            let database_entries = try self.database_connection.prepare(self.database_table)
            self.database_entries = database_entries
        }
        catch
        {
            print("connectDatabase():\n", error)
        }
    }
    
    func getDatabaseEntries() -> [DataModel]
    {
        var DatabaseEntryArray = [DataModel]()
        
        for entry in database_entries
        {
            DatabaseEntryArray.append(DataModel(
                Expression: entry[self.expression],
                Explanation: entry[self.explanation],
                Elaboration: entry[self.elaboration]))
        }
        
        return DatabaseEntryArray
    }
}
