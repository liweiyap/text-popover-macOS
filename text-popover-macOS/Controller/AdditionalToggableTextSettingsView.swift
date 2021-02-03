//
//  AdditionalToggableTextSettingsView.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 10.08.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI

final class AdditionalToggableTextOptions: ObservableObject
{
    @Published var displayExplanation: Bool = true
    @Published var displayElaboration: Bool = false
}

struct AdditionalToggableTextSettingsView: View
{
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Toggle(isOn: $additionalToggableTextOptions.displayExplanation)
            {
                Text("Display Explanation")
            }
            
            Toggle(isOn: $additionalToggableTextOptions.displayElaboration)
            {
                Text("Display Elaboration")
            }
        }
    }
}
