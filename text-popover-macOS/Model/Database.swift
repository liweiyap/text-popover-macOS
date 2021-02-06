//
//  Database.swift
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
protocol Database
{
    func createDBFile(_ database_path: String) -> Void
    func connectDBFile(_ database_path: String) -> Void
    func readDBFile() -> Void
    func getRandomDatabaseEntry() -> DataModel
    func getDatabaseEntryCount() -> Int
    func getDBFileConnection() -> Connection!
}

/*
 * SQLite cannot be imported into any .swift files that contain SwiftUI Views.
 * (https://github.com/stephencelis/SQLite.swift/issues/980)
 * Since I don't want DatabaseGermanIdiomsImpl to have this function,
 * I have no choice but to have this function as a stand-alone (outside a class/protocol)
 * in this very file.
 */
func addRowToDatabase(_ database: Database, _ databaseName: String, _ entry: DataModel) -> Void
{
    assert(databaseName != "Redewendungen",
           "DatabaseGermanIdiomsImpl designed to be non-editable by user.")
    
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
        try database.getDBFileConnection().run(row)
        print("New entry added to database \(databaseName).")
        database.readDBFile()
    }
    catch
    {
        print("addRowToDatabase():\n", error)
    }
}

/*
 * SQLite cannot be imported into any .swift files that contain SwiftUI Views.
 * (https://github.com/stephencelis/SQLite.swift/issues/980)
 * Since I don't want DatabaseGermanIdiomsImpl to have this function,
 * I have no choice but to have this function as a stand-alone (outside a class/protocol)
 * in this very file.
 */
func removeRowFromDatabase(_ database: Database, _ databaseName: String, _ expr: String) -> Int
{
    assert(databaseName != "Redewendungen",
           "DatabaseGermanIdiomsImpl designed to be non-editable by user.")
    
    let databaseTable = Table(databaseName)
    let expression = Expression<String>("Expression")
    
    do
    {
        _ = try database.getDBFileConnection().prepare(databaseTable)
        let databaseEntries = databaseTable.filter(expression == expr)
        
        if try database.getDBFileConnection().scalar(databaseEntries.count) == 0
        {
            print("Entry not found in database \(databaseName).")
            return -1
        }
        
        try database.getDBFileConnection().run(databaseEntries.delete())
        print("Old entry removed from database \(databaseName).")
        database.readDBFile()
        return 0
    }
    catch
    {
        print("removeRowFromDatabase():\n", error)
        return -1
    }
}

final class DatabaseGeneralIdiomsImpl: Database
{
    private var database_connection: Connection!
    private let database_name: String
    private let expression = Expression<String>("Expression")
    private let explanation = Expression<String>("Explanation")
    private let elaboration = Expression<String>("Elaboration")
    
    private var DatabaseEntryArray = [DataModel]()
    
    init(_ database_name: String)
    {
        self.database_name = database_name
        createDBFile(database_name)
        readDBFile()
    }
    
    func createDBFile(_ database_name: String) -> Void
    {
        do
        {
            let database_path: String = URL(fileURLWithPath: #file).deletingLastPathComponent().path +
                "/../../text-popover-macOSDatabaseFiles/" + database_name + ".db"
            connectDBFile(database_path)
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
            print("DatabaseGeneralIdiomsImpl::createDBFile():\n", error)
        }
    }
    
    func connectDBFile(_ database_path: String) -> Void
    {
        do
        {
            let database_connection = try Connection(database_path)
            self.database_connection = database_connection
        }
        catch
        {
            print("DatabaseGeneralIdiomsImpl::connectDBFile():\n", error)
        }
    }
    
    func readDBFile() -> Void
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
            print("DatabaseGeneralIdiomsImpl::readDBFile():\n", error)
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
    
    func getDBFileConnection() -> Connection!
    {
        return database_connection
    }
}

final class DatabaseGermanIdiomsImpl: Database
{
    private var database_connection: Connection!
    private let database_table = Table("Redewendungen")
    private let expression = Expression<String>("Expression")
    private let explanation = Expression<String>("Explanation")
    private let elaboration = Expression<String>("Elaboration")
    
    private var DatabaseEntryArray = [DataModel]()
    
    private enum DatabaseGermanIdiomsImplError: Error
    {
        case PythonNotFound
    }

    init(_ database_path: String, _ do_create_database: Bool)
    {
        if do_create_database
        {
            createDBFile(database_path)
        }
        connectDBFile(database_path)
        readDBFile()
    }
    
    func createDBFile(_ database_path: String) -> Void
    {
        do
        {
            let fileUrl = URL(fileURLWithPath: #file)
            let dirUrl = fileUrl.deletingLastPathComponent()
            let python_script_path = dirUrl.path + "/../../text-popover-macOSDatabaseFiles/create_database_german_idioms_impl.py"
            let bash_env_launch_path = "/bin/bash"
            
            let enquiryProcess = Process()
            enquiryProcess.arguments = ["-l", "-c", "which python3"]
            enquiryProcess.launchPath = bash_env_launch_path
            let pipe = Pipe()
            enquiryProcess.standardOutput = pipe
            try enquiryProcess.run()
            
            /*
             * Strip newline char from the end of the output
             */
            let pipeOutput = pipe.fileHandleForReading.readDataToEndOfFile()
            let tmpOptional = String(data: pipeOutput, encoding: .utf8)
            if tmpOptional == nil
            {
                throw DatabaseGermanIdiomsImplError.PythonNotFound
            }
            let tmp = tmpOptional!.trimmingCharacters(in: .newlines)
            let python_env_launch_path = tmp.components(separatedBy: "\n")[0]
            
            let runProcess = Process()
            runProcess.arguments = [python_script_path, database_path]
            runProcess.launchPath = python_env_launch_path
            try runProcess.run()
        }
        catch DatabaseGermanIdiomsImplError.PythonNotFound
        {
            print("DatabaseGermanIdiomsImpl::createDBFile(): External Python executable not found. Please check that one has been installed.\n")
        }
        catch
        {
            print("DatabaseGermanIdiomsImpl::createDBFile():\n", error)
        }
    }
    
    func connectDBFile(_ database_path: String) -> Void
    {
        do
        {
            let database_connection = try Connection(database_path)
            self.database_connection = database_connection
        }
        catch
        {
            print("DatabaseGermanIdiomsImpl::connectDBFile():\n", error)
        }
    }
    
    func readDBFile() -> Void
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
            print("DatabaseGermanIdiomsImpl::readDBFile():\n", error)
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
    
    func getDBFileConnection() -> Connection!
    {
        return database_connection
    }
}
