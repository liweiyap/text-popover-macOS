//
//  SettingsButton.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 30.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI
import Combine

struct SettingsButton: View
{
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    var body: some View
    {
        MenuButton(">")
        {
            Button("5 Sekunden", action: {
                self.timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
            })
            
            Button("24 Stunden", action: {
                self.timer = Timer.publish(every: TimeInterval(24 * Int.secondsPerHour), on: .main, in: .common).autoconnect()
            })
        }
        .frame(width: 10.0)
        .menuButtonStyle(BorderlessButtonMenuButtonStyle())
    }
}
