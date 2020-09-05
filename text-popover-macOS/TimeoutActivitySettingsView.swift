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
    
    @Published var soundOnTimeout: NSSound? = nil
    @Published var soundMenuButtonName: String = "Sound"
}

struct TimeoutActivitySettingsView: View
{
    @EnvironmentObject var timeoutActivityOptions: TimeoutActivityOptions
    let sounds = ["Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero",
                  "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"]
    
    static var soundMenuButtonWidth: CGFloat = 110.0
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Toggle(isOn: $timeoutActivityOptions.showPopoverOnTimeout)
            {
                Text("Pop up on timeout")
            }
            
            MenuButton(timeoutActivityOptions.soundMenuButtonName)
            {
                Button("No sound")
                {
                    self.timeoutActivityOptions.soundOnTimeout = nil
                    self.timeoutActivityOptions.soundMenuButtonName = "No sound"
                }
                
                ForEach(sounds, id: \.self)
                {
                    sound in
                    
                    Button(sound)
                    {
                        self.timeoutActivityOptions.soundOnTimeout = NSSound(named: sound)
                        self.timeoutActivityOptions.soundMenuButtonName = sound
                    }
                }
            }
            .frame(width: TimeoutActivitySettingsView.soundMenuButtonWidth)
        }
    }
}
