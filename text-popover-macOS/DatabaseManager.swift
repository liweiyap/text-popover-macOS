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
    func createDatabase(_ database_path: String) -> Void
    func connectDatabase(_ database_path: String) -> Void
    func readDatabase() -> Void
    func getRandomDatabaseEntry() -> DataModel
    func getDatabaseEntryCount() -> Int
    func getDatabaseConnection() -> Connection!
}

/*
 * SQLite cannot be imported into any .swift files that contain SwiftUI Views.
 * (https://github.com/stephencelis/SQLite.swift/issues/980)
 * Since I don't want DatabaseManagerGermanIdiomsImpl to have this function,
 * I have no choice but to have this function as a stand-alone (outside a class/protocol)
 * in this very file.
 */
func addRowToDatabase(_ databaseManager: DatabaseManager, _ databaseName: String, _ entry: DataModel) -> Void
{
    assert(databaseName != "Redewendungen",
           "DatabaseManagerGermanIdiomsImpl designed to be non-editable by user.")
    
    let databaseTable = Table(databaseName)
    let expression = Expression<String>("Expression")
    let explanation = Expression<String>("Explanation")
    let elaboration = Expression<String>("Elaboration")
    
    let row = databaseTable.insert(
        expression <- entry.Expression,
        explanation <- entry.Explanation,
        elaboration <- entry.Elaboration)
    
    do
    {
        try databaseManager.getDatabaseConnection().run(row)
        print("New entry added to database \(databaseName).")
        databaseManager.readDatabase()
    }
    catch
    {
        print("addRowToDatabase():\n", error)
    }
}

/*
 * SQLite cannot be imported into any .swift files that contain SwiftUI Views.
 * (https://github.com/stephencelis/SQLite.swift/issues/980)
 * Since I don't want DatabaseManagerGermanIdiomsImpl to have this function,
 * I have no choice but to have this function as a stand-alone (outside a class/protocol)
 * in this very file.
 */
func removeRowFromDatabase(_ databaseManager: DatabaseManager, _ databaseName: String, _ expr: String) -> Void
{
    assert(databaseName != "Redewendungen",
           "DatabaseManagerGermanIdiomsImpl designed to be non-editable by user.")
    
    let databaseTable = Table(databaseName)
    let expression = Expression<String>("Expression")
    
    do
    {
        _ = try databaseManager.getDatabaseConnection().prepare(databaseTable)
        let databaseEntries = databaseTable.filter(expression == expr)
        
        if try databaseManager.getDatabaseConnection().scalar(databaseEntries.count) == 0
        {
            print("Entry not found in database \(databaseName).")
            return
        }
        
        try databaseManager.getDatabaseConnection().run(databaseEntries.delete())
        print("Old entry removed from database \(databaseName).")
        databaseManager.readDatabase()
    }
    catch
    {
        print("removeRowFromDatabase():\n", error)
    }
}

final class DatabaseManagerGeneralIdiomsImpl: DatabaseManager
{
    var database_connection: Connection!
    let database_name: String
    let expression = Expression<String>("Expression")
    let explanation = Expression<String>("Explanation")
    let elaboration = Expression<String>("Elaboration")
    
    var DatabaseEntryArray = [DataModel]()
    
    init(_ database_name: String)
    {
        self.database_name = database_name
        createDatabase(database_name)
        readDatabase()
    }
    
    func createDatabase(_ database_name: String) -> Void
    {
        do
        {
            let database_path: String = URL(fileURLWithPath: #file).deletingLastPathComponent().path +
                "/../text-popover-macOSUtils/" + database_name + ".db"
            connectDatabase(database_path)
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
            let database_table = Table(database_name)
            let database_entries = try database_connection.prepare(database_table)
            
            DatabaseEntryArray.removeAll()
            
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
        let nEntries: Int = getDatabaseEntryCount()
        
        if nEntries > 0
        {
            let randomDatabaseEntryIdx = Int.random(in: 0 ... (nEntries-1))

            return DatabaseEntryArray[randomDatabaseEntryIdx]
        }
        
        return DataModel(Expression: "", Explanation: "", Elaboration: "")
    }
    
    func getDatabaseEntryCount() -> Int
    {
        return DatabaseEntryArray.count
    }
    
    func getDatabaseConnection() -> Connection!
    {
        return database_connection
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
        let nEntries: Int = getDatabaseEntryCount()
        
        if nEntries > 0
        {
            let randomDatabaseEntryIdx = Int.random(in: 0 ... (nEntries-1))

            return DatabaseEntryArray[randomDatabaseEntryIdx]
        }
        
        return DataModel(Expression: "", Explanation: "", Elaboration: "")
    }
    
    func getDatabaseEntryCount() -> Int
    {
        return DatabaseEntryArray.count
    }
    
    func getDatabaseConnection() -> Connection!
    {
        return database_connection
    }
}
