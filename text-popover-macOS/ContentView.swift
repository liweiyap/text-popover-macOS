//
//  ContentView.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 13.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI

struct ContentView: View
{
    @State var name: String = ""
    @State var email: String = ""
    
    let myData = DatabaseManager(URL(fileURLWithPath: #file).deletingLastPathComponent().path + "/../text-popover-macOSUtils/redewendungen.db")
    
    var body: some View
    {
        VStack
        {
            TextField("Enter Name", text: self.$name)
            TextField("Enter email", text: self.$email)
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
