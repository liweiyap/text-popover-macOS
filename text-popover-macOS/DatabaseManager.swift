//
//  DatabaseManager.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 15.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SQLite

struct DataModel: Hashable
{
    let Expression: String
    let Explanation: String
    let Elaboration: String
}

/*
 * Base abstract class / Interface
 */
protocol DatabaseManager
{
    func getRandomDatabaseEntry() -> DataModel
}

final class DatabaseManagerGeneralIdiomsImpl: DatabaseManager
{
    var database_connection: Connection!
    let database_table = Table("Idioms")
    let expression = Expression<String>("Expression")
    let explanation = Expression<String>("Explanation")
    let elaboration = Expression<String>("Elaboration")
    
    var DatabaseEntryArray = [DataModel]()
    
    init(_ database_name: String)
    {
        createDatabase(database_name)
//        connectDatabase(database_path)
//        readDatabase()
    }
    
    func createDatabase(_ database_name: String) -> Void
    {
        do
        {
            let database_path: String = URL(fileURLWithPath: #file).deletingLastPathComponent().path +
                "/../text-popover-macOSUtils/" + database_name + ".db"
            let database_connection = try Connection(database_path)
            let database_table = Table(database_name)
            
            for tableNames in try database_connection.prepare("SELECT name FROM sqlite_master WHERE type='table';")
            {
                if tableNames.count > 0
                {
                    return
                }
            }
            
            try database_connection.run(database_table.create
            {
                table in
                
                table.column(expression)
                table.column(explanation)
                table.column(elaboration)
            })
        }
        catch
        {
            print("DatabaseManagerGeneralIdiomsImpl::createDatabase():\n", error)
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
            print("DatabaseManagerGeneralIdiomsImpl::connectDatabase():\n", error)
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
            print("DatabaseManagerGeneralIdiomsImpl::readDatabase():\n", error)
        }
    }
    
    func getRandomDatabaseEntry() -> DataModel
    {
        let nEntries: Int = DatabaseEntryArray.count
        
        if nEntries > 0
        {
            let randomDatabaseEntryIdx = Int.random(in: 0 ... (nEntries-1))

            return DatabaseEntryArray[randomDatabaseEntryIdx]
        }
        
        return DataModel(Expression: "", Explanation: "", Elaboration: "")
    }
}

final class DatabaseManagerGermanIdiomsImpl: DatabaseManager
{
    var database_connection: Connection!
    let database_table = Table("Redewendungen")
    let expression = Expression<String>("Expression")
    let explanation = Expression<String>("Explanation")
    let elaboration = Expression<String>("Elaboration")
    
    var DatabaseEntryArray = [DataModel]()

    init(_ database_path: String, _ do_create_database: Bool)
    {
        if do_create_database
        {
            createDatabase(database_path)
        }
        connectDatabase(database_path)
        readDatabase()
    }
    
    func createDatabase(_ database_path: String) -> Void
    {
        let fileUrl = URL(fileURLWithPath: #file)
        let dirUrl = fileUrl.deletingLastPathComponent()
        let python_script_path = dirUrl.path + "/../text-popover-macOSUtils/create_database_german_idioms_impl.py"
        
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
            print("DatabaseManagerGermanIdiomsImpl::createDatabase():\n", error)
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
            print("DatabaseManagerGermanIdiomsImpl::connectDatabase():\n", error)
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
            print("DatabaseManagerGermanIdiomsImpl::readDatabase():\n", error)
        }
    }
    
    func getRandomDatabaseEntry() -> DataModel
    {
        let nEntries: Int = DatabaseEntryArray.count
        
        if nEntries > 0
        {
            let randomDatabaseEntryIdx = Int.random(in: 0 ... (nEntries-1))

            return DatabaseEntryArray[randomDatabaseEntryIdx]
        }
        
        return DataModel(Expression: "", Explanation: "", Elaboration: "")
    }
}
