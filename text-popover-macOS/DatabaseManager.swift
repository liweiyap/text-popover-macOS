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
    
    struct DataModel: Hashable
    {
        let Expression: String
        let Explanation: String
        let Elaboration: String
    }
    
    var DatabaseEntryArray = [DataModel]()

    init(_ database_path: String)
    {
        createDatabase(database_path)
        connectDatabase(database_path)
        readDatabase()
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
        }
        catch
        {
            print("connectDatabase():\n", error)
        }
    }
    
    func readDatabase() -> Void
    {
        do
        {
            let database_entries = try database_connection.prepare(database_table)
            
            for entry in database_entries
            {
                DatabaseEntryArray.append(DataModel(
                    Expression: entry[self.expression],
                    Explanation: entry[self.explanation],
                    Elaboration: entry[self.elaboration]))
            }
        }
        catch
        {
            print("readDatabase():\n", error)
        }
    }
    
    func getRandomDatabaseEntry() -> DataModel
    {
        let nEntries: Int = DatabaseEntryArray.count
        
        if (nEntries > 0)
        {
            let randomDatabaseEntryIdx = Int.random(in: 0 ... (nEntries-1))

            return DatabaseEntryArray[randomDatabaseEntryIdx]
        }
        
        return DataModel(Expression: "", Explanation: "", Elaboration: "")
    }
}
