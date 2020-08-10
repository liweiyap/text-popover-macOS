//
//  AdditionalToggableTextSettingsView.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 10.08.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI

struct AdditionalToggableTextSettingsView: View
{
    @Binding var displayExplanation: Bool
    @Binding var displayElaboration: Bool
    
    var body: some View
    {
        VStack
        {
            Toggle(isOn: $displayExplanation)
            {
                Text("Display Explanation")
            }
            
            Toggle(isOn: $displayElaboration)
            {
                Text("Display Elaboration")
            }
        }
    }
}
