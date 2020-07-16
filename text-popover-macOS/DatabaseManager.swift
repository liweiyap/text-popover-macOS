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
            shell()
            
            let database_connection = try Connection(database_path)
            self.database_connection = database_connection
            print("Database initialized at path \(database_path)")
        }
        catch
        {
            print(error)
        }
    }

    func shell() -> Void
    {
        let task = Process()

        task.arguments = ["/Users/leewayleaf/Documents/Repositories/text-popover-macOS/create_database.py"]
        task.executableURL = URL(fileURLWithPath: "/Users/leewayleaf/opt/anaconda3/bin/python3")
        do
        {
            try task.run()
        }
        catch
        {
            print(error)
        }
    }
}
