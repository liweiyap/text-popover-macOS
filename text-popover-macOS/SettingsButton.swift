//
//  SettingsButton.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 30.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI
import Combine

struct SingleGeneralSettingView<Content:View>: View
{
    var label: String
    var labelWidthProportion: CGFloat
    
    var view: Content
    var viewWidthProportion: CGFloat
    
    init(label: String, view: Content)
    {
        self.label = label
        labelWidthProportion = 3.0/8.0
        
        self.view = view
        viewWidthProportion = 5.0/8.0
        
        assert(abs(labelWidthProportion + viewWidthProportion - 1.0) < 1e-3,
               "SingleGeneralSettingView::init(): The sum of both labelWidthProportion and viewWidthProportion must be equal to 1.")
    }
    
    var body: some View
    {
        HStack(alignment: .firstTextBaseline)
        {
            Text("\(label):")
            .frame(width: CGFloat(SettingsButton.SettingsWindowWidth) * labelWidthProportion,
                   alignment: .trailing)
            
            view
            .frame(width: CGFloat(SettingsButton.SettingsWindowWidth) * viewWidthProportion,
                   alignment: .leading)
        }
    }
}

struct GeneralSettingsView: View
{
    var body: some View
    {
        VStack(alignment: .center)
        {
            SingleGeneralSettingView(label: "Interval", view: IntervalSettingsView())
            Divider()
            SingleGeneralSettingView(label: "Activity on timeout", view: TimeoutActivitySettingsView())
            Divider()
            SingleGeneralSettingView(label: "Additional texts", view: AdditionalToggableTextSettingsView())
            Divider()
            SingleGeneralSettingView(label: "Background", view: BackgroundSettingsView())
            Spacer()
        }
    }
}

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
    @EnvironmentObject var databaseManagerWrapper: DatabaseManagerWrapper
    @Binding var lastSelectedDatabaseManager: String?
    
    var body: some View
    {
        List(databaseManagerWrapper.getDatabaseNames(), id: \.self, selection: $lastSelectedDatabaseManager)
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
                    if lastSelectedDatabaseManager != databaseName
                    {
                        databaseManagerWrapper.databaseManager = DatabaseManagerGermanIdiomsImpl(
                            URL(fileURLWithPath: #file).deletingLastPathComponent().path +
                            "/../text-popover-macOSUtils/german-idioms.db", false)
                    }
                    
                    lastSelectedDatabaseManager = databaseName
                })
            }
            else
            {
                DatabaseListText(databaseName: databaseName, onTapActivity:
                {
                    if lastSelectedDatabaseManager != databaseName
                    {
                        databaseManagerWrapper.databaseManager = DatabaseManagerGeneralIdiomsImpl(databaseName)
                    }
                    
                    lastSelectedDatabaseManager = databaseName
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
         */
    }
}

struct DatabaseListToolbar: View
{
    @EnvironmentObject var databaseManagerWrapper: DatabaseManagerWrapper
    @Binding var lastSelectedDatabaseManager: String?
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            DatabaseListToolbarButton(imageName: NSImage.addTemplateName, buttonActivity: {
                databaseManagerWrapper.toAddNewDatabase = true
            })
            .disabled(databaseManagerWrapper.toAddNewDatabase)
            
            Divider()
            
            DatabaseListToolbarButton(imageName: NSImage.removeTemplateName, buttonActivity: {})
            .disabled(lastSelectedDatabaseManager == "Redewendungen")
            
            Divider()
            
            Spacer()
        }
        .frame(height: DatabaseListToolbarButton.DatabaseListToolbarButtonDimensions)
    }
}

struct DatabaseSelector: View
{
    @Binding var lastSelectedDatabaseManager: String?
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            DatabaseList(lastSelectedDatabaseManager: $lastSelectedDatabaseManager)
            DatabaseListToolbar(lastSelectedDatabaseManager: $lastSelectedDatabaseManager)
        }
        .border(Color(NSColor.gridColor), width: 1)
    }
}

struct AddNewDatabaseHelper: View
{
    @EnvironmentObject var databaseManagerWrapper: DatabaseManagerWrapper
    @State var newDatabaseName: String = ""
    
    @Binding var lastSelectedDatabaseManager: String?
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
                    
                    if databaseManagerWrapper.toAddNewDatabase
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
                                    databaseManagerWrapper.databaseManager = DatabaseManagerGeneralIdiomsImpl(newDatabaseName)
                                }
                                
                                newDatabaseName = ""
                                databaseManagerWrapper.toAddNewDatabase = false
                            }
                            .disabled(newDatabaseName == "")
                            
                            Button("Back")
                            {
                                newDatabaseName = ""
                                databaseManagerWrapper.toAddNewDatabase = false
                            }
                        }
                    }
                    else
                    {
                        if lastSelectedDatabaseManager == "Redewendungen"
                        {
                            Text("Click Add (+) to add a new Database.")
                        }
                        else
                        {
                            Text("Add new entry to database \(lastSelectedDatabaseManager!):")
                            TextField("Expression", text: $newDatabaseEntryExpression)
                            TextField("Explanation", text: $newDatabaseEntryExplanation)
                            TextField("Elaboration", text: $newDatabaseEntryElaboration)
                            Button("Add")
                            {
                                
                            }
                            
                            Text("Remove entry from database \(lastSelectedDatabaseManager!):")
                            TextField("Expression", text: $oldDatabaseEntryExpression)
                            Button("Remove")
                            {
                                
                            }
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
    @State var lastSelectedDatabaseManager: String? = "Redewendungen"
    
    let centerSpacing: CGFloat = 20
    
    var body: some View
    {
        HStack(spacing: centerSpacing)
        {
            DatabaseSelector(lastSelectedDatabaseManager: $lastSelectedDatabaseManager)
            .frame(width: (CGFloat(SettingsButton.SettingsWindowWidth) - centerSpacing) * 3.0/10.0)
            
            AddNewDatabaseHelper(lastSelectedDatabaseManager: $lastSelectedDatabaseManager)
            .frame(width: (CGFloat(SettingsButton.SettingsWindowWidth) - centerSpacing) * 7.0/10.0)
        }
        .padding()
    }
}

struct AllSettingsView: View
{
    var body: some View
    {
        TabView
        {
            GeneralSettingsView()
            .tabItem
            {
                Text("General")
            }
            
            DatabaseSelectionView()
            .tabItem
            {
                Text("Databases")
            }
        }
    }
}

struct SettingsButton: View
{
    @EnvironmentObject var databaseManagerWrapper: DatabaseManagerWrapper
    @EnvironmentObject var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    @EnvironmentObject var timeoutActivityOptions: TimeoutActivityOptions
    @EnvironmentObject var backgroundOptions: BackgroundOptions
    @EnvironmentObject var intervalMenuButtonNames: IntervalMenuButtonNames
    
    @State var window: NSWindow?
    
    static let SettingsButtonDimensions: Int = 20
    static let SettingsWindowWidth: Int = 480
    static let SettingsWindowHeight: Int = 330
    
    var body: some View
    {
        Button(action: {
            let allSettingsView = AllSettingsView()
                .environmentObject(databaseManagerWrapper)
                .environmentObject(countdownTimerWrapper)
                .environmentObject(additionalToggableTextOptions)
                .environmentObject(timeoutActivityOptions)
                .environmentObject(backgroundOptions)
                .environmentObject(intervalMenuButtonNames)
            
            if window != nil
            {
                window!.close()
                window = nil
            }
            
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0,
                                    width: SettingsButton.SettingsWindowWidth,
                                    height: SettingsButton.SettingsWindowHeight),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window!.center()
            window!.setFrameAutosaveName("Settings")
            window!.title = "Settings"
            window!.contentView = NSHostingView(rootView: allSettingsView)
            window!.orderFrontRegardless()
            window!.isReleasedWhenClosed = false
        })
        {
            /*
             * For some reason, when `Text("⚙").font(.title)` is used, there is some vspace above the ⚙?
             *
             * Use .resized() as an alternative to `Image(nsImage).scaledToFit()`
             */
            Image(nsImage: NSImage(named: NSImage.advancedName)!
                .resized(to: NSSize(width: SettingsButton.SettingsButtonDimensions,
                                    height: SettingsButton.SettingsButtonDimensions))!)
            .renderingMode(.original)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
