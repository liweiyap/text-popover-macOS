//
//  TimeoutActivitySettingsView.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 05.09.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI

final class TimeoutActivityOptions: ObservableObject
{
    @Published var showPopoverOnTimeout: Bool = true
}

struct TimeoutActivitySettingsView: View
{
    @EnvironmentObject var timeoutActivityOptions: TimeoutActivityOptions
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Toggle(isOn: $timeoutActivityOptions.showPopoverOnTimeout)
            {
                Text("Pop up on timeout")
            }
        }
    }
}
