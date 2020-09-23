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
    @Published var darkMode: Bool = true
    {
        didSet
        {
            toggleBackgroundColour()
        }
    }
    
    func toggleBackgroundColour() -> Void
    {
        if (darkMode)
        {
            AppDelegate.selfInstance?.popover.appearance = NSAppearance(named: .darkAqua)
        }
        else
        {
            AppDelegate.selfInstance?.popover.appearance = NSAppearance(named: .aqua)
        }
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
