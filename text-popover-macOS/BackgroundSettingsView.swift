//
//  BackgroundSettingsView.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 23.09.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI

final class BackgroundOptions: ObservableObject
{
    /*
     * We use Bool instead of ColorScheme because of Toggle in BackgroundSettingsView
     */
    @Published var darkMode: Bool = true
    {
        didSet
        {
            toggleBackgroundColour()
        }
    }
    
    /*
     * Changes the NSPopover arrow colour too
     */
    func toggleBackgroundColour() -> Void
    {
        AppDelegate.selfInstance?.popover.appearance = NSAppearance(named: darkMode ? .darkAqua : .aqua)
    }
}

struct BackgroundSettingsView: View
{
    @EnvironmentObject var backgroundOptions: BackgroundOptions
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Toggle(isOn: $backgroundOptions.darkMode)
            {
                Text("Dark mode")
            }
        }
    }
}
