//
//  DatabaseSelectionView.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 02.02.21.
//  Copyright © 2021 Li-Wei Yap. All rights reserved.
//

import SwiftUI
import Combine

struct DatabaseListText: View
{
    let databaseName: String
    let onTapActivity: () -> Void
    
    var body: some View
    {
        Text(databaseName)
        /*
         * Allows us to make the whole area (not just the text) tappable
         */
        .contentShape(Rectangle())
        .onTapGesture {
            onTapActivity()
        }
    }
}

/*
 * https://www.notion.so/SwiftUI-on-macOS-Selection-in-List-c3c5505255db40488d55a16b08bad832
 */
struct DatabaseList: View
{
    @EnvironmentObject var databaseManager: DatabaseManager
    @Binding var lastSelectedDatabase: String?
    
    var body: some View
    {
        List(databaseManager.getDatabaseNames(), id: \.self, selection: $lastSelectedDatabase)
        {
            databaseName in
            
            /*
             * `german-idioms.db` is the default database that will
             * always be present in text-popover-macOSUtils/,
             * hence the decision to hard-code the logic upon selection in DatabaseList
             */
            if (databaseName == "Redewendungen")
            {
                DatabaseListText(databaseName: databaseName, onTapActivity:
                {
                    if lastSelectedDatabase != databaseName
                    {
                        print("New database selected: \(databaseName)")
                        databaseManager.database = DatabaseGermanIdiomsImpl(
                            URL(fileURLWithPath: #file).deletingLastPathComponent().path +
                            "/../text-popover-macOSUtils/german-idioms.db", false)
                        databaseManager.notifyDatabasesChanged()
                    }
                    
                    lastSelectedDatabase = databaseName
                })
            }
            else
            {
                DatabaseListText(databaseName: databaseName, onTapActivity:
                {
                    if lastSelectedDatabase != databaseName
                    {
                        print("New database selected: \(databaseName)")
                        databaseManager.database = DatabaseGeneralIdiomsImpl(databaseName)
                        databaseManager.notifyDatabasesChanged()
                    }
                    
                    lastSelectedDatabase = databaseName
                })
            }
        }
        /*
         * The following allows List to be an alternative to
         * `ScrollView(.vertical, showsIndicators: false) {}`
         * by disabling scrollbars
         */
        .onNSView(added: {
            nsView in

            let root = nsView.subviews[0] as! NSScrollView

            root.hasVerticalScroller = false
            root.hasHorizontalScroller = false
        })
    }
}

struct DatabaseListToolbarButton: View
{
    static let DatabaseListToolbarButtonDimensions: CGFloat = 20.0
    let imageName: String
    let buttonActivity: () -> Void

    var body: some View
    {
        Button(action: buttonActivity)
        {
            Image(nsImage: NSImage(named: imageName)!)
            .resizable()
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(width: DatabaseListToolbarButton.DatabaseListToolbarButtonDimensions,
               height: DatabaseListToolbarButton.DatabaseListToolbarButtonDimensions)
        /*
         * .contentShape(Rectangle()) does not work, for some reason
         * thus, we can't make the whole rectangular area outside the image tappable
         */
    }
}

struct DatabaseListToolbar: View
{
    @EnvironmentObject var databaseManager: DatabaseManager
    @Binding var lastSelectedDatabase: String?
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            DatabaseListToolbarButton(imageName: NSImage.addTemplateName, buttonActivity: {
                databaseManager.toAddNewDatabase = true
            })
            .disabled(databaseManager.toAddNewDatabase)
            
            Divider()
            
            DatabaseListToolbarButton(imageName: NSImage.removeTemplateName, buttonActivity: {
                if lastSelectedDatabase != nil
                {
                    let oldDatabasePath: String = URL(fileURLWithPath: #file).deletingLastPathComponent().path +
                        "/../text-popover-macOSUtils/" + lastSelectedDatabase! + ".db"
                    
                    do
                    {
                        lastSelectedDatabase = "Redewendungen"
                        print("New database selected: Redewendungen")
                        databaseManager.database = DatabaseGermanIdiomsImpl(
                            URL(fileURLWithPath: #file).deletingLastPathComponent().path +
                            "/../text-popover-macOSUtils/german-idioms.db", false)
                        databaseManager.notifyDatabasesChanged()
                        try FileManager.default.removeItem(atPath: oldDatabasePath)
                    }
                    catch
                    {
                        print("DatabaseListToolbarButton.buttonActivity:\n", error)
                    }
                }
            })
            .disabled(lastSelectedDatabase == "Redewendungen")
            
            Divider()
            
            Spacer()
        }
        .frame(height: DatabaseListToolbarButton.DatabaseListToolbarButtonDimensions)
    }
}

struct DatabaseSelector: View
{
    @Binding var lastSelectedDatabase: String?
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            DatabaseList(lastSelectedDatabase: $lastSelectedDatabase)
            DatabaseListToolbar(lastSelectedDatabase: $lastSelectedDatabase)
        }
        .border(Color(NSColor.gridColor), width: 1)
    }
}

struct AddNewDatabaseHelper: View
{
    @EnvironmentObject var databaseManager: DatabaseManager
    @State var newDatabaseName: String = ""
    
    @Binding var lastSelectedDatabase: String?
    @State var newDatabaseEntryExpression: String = ""
    @State var newDatabaseEntryExplanation: String = ""
    @State var newDatabaseEntryElaboration: String = ""
    @State var oldDatabaseEntryExpression: String = ""
    
    var body: some View
    {
        GeometryReader
        {
            geometry in
            
            HStack
            {
                Spacer()
                
                VStack
                {
                    Spacer()
                    
                    if databaseManager.toAddNewDatabase
                    {
                        TextField("Name of database", text: $newDatabaseName)
                        
                        Spacer()
                        .frame(height: geometry.size.height * 1.0/8.0)
                        
                        HStack
                        {
                            Button("Create")
                            {
                                if (newDatabaseName == "Redewendungen" || newDatabaseName == "german-idioms")
                                {
                                    print("Please select another name.")
                                    return
                                }
                                
                                let newDatabasePath: String = URL(fileURLWithPath: #file).deletingLastPathComponent().path +
                                    "/../text-popover-macOSUtils/" + newDatabaseName + ".db"
                                
                                if (FileManager.default.fileExists(atPath: newDatabasePath))
                                {
                                    print("Database already exists.")
                                    return
                                }
                                else
                                {
                                    databaseManager.database = DatabaseGeneralIdiomsImpl(newDatabaseName)
                                }
                                
                                newDatabaseName = ""
                                databaseManager.toAddNewDatabase = false
                            }
                            .disabled(newDatabaseName == "")
                            
                            Button("Back")
                            {
                                newDatabaseName = ""
                                databaseManager.toAddNewDatabase = false
                            }
                        }
                    }
                    else
                    {
                        if lastSelectedDatabase == "Redewendungen"
                        {
                            Text("Click Add (+) to add a new Database.")
                        }
                        else if lastSelectedDatabase != nil
                        {
                            Text("Add new entry to database \(lastSelectedDatabase!):")
                            TextField("Expression", text: $newDatabaseEntryExpression)
                            TextField("Explanation", text: $newDatabaseEntryExplanation)
                            TextField("Elaboration", text: $newDatabaseEntryElaboration)
                            Button("Add")
                            {
                                addRowToDatabase(databaseManager.database,
                                                 lastSelectedDatabase!,
                                                 DataModel(Expression: newDatabaseEntryExpression,
                                                           Explanation: newDatabaseEntryExplanation,
                                                           Elaboration: newDatabaseEntryElaboration))
                                
                                newDatabaseEntryExpression = ""
                                newDatabaseEntryExplanation = ""
                                newDatabaseEntryElaboration = ""
                                
                                if databaseManager.getDatabaseEntryCount() == 1
                                {
                                    databaseManager.notifyDatabasesChanged()
                                }
                            }
                            .disabled(newDatabaseEntryExpression == "")
                            
                            Text("Remove entry from database \(lastSelectedDatabase!):")
                            TextField("Expression", text: $oldDatabaseEntryExpression)
                            Button("Remove")
                            {
                                removeRowFromDatabase(databaseManager.database,
                                                      lastSelectedDatabase!,
                                                      oldDatabaseEntryExpression)
                                
                                oldDatabaseEntryExpression = ""
                                
                                databaseManager.notifyDatabasesChanged()
                            }
                            .disabled(oldDatabaseEntryExpression == "")
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .font(Font.system(size: 15))
            .background(Color(NSColor.unemphasizedSelectedContentBackgroundColor))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color(NSColor.gridColor)))
        }
    }
}

struct DatabaseSelectionView: View
{
    @State var lastSelectedDatabase: String? = "Redewendungen"
    
    let centerSpacing: CGFloat = 20
    
    var body: some View
    {
        HStack(spacing: centerSpacing)
        {
            DatabaseSelector(lastSelectedDatabase: $lastSelectedDatabase)
            .frame(width: (CGFloat(SettingsButton.SettingsWindowWidth) - centerSpacing) * 3.0/10.0)
            
            AddNewDatabaseHelper(lastSelectedDatabase: $lastSelectedDatabase)
            .frame(width: (CGFloat(SettingsButton.SettingsWindowWidth) - centerSpacing) * 7.0/10.0)
        }
        .padding()
    }
}
