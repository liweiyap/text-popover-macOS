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

    init(_ database_path: String)
    {
        do
        {
            createDatabase()
            
            let database_connection = try Connection(database_path)
            self.database_connection = database_connection
        }
        catch
        {
            print(error)
        }
    }

    func createDatabase() -> Void
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
        process.arguments = [python_script_path]
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
}
