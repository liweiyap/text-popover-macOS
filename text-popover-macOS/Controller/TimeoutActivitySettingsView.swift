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
    @Published var soundVolume: Float = 1.0
}

fileprivate struct SoundVolumeSlider: View
{
    @EnvironmentObject private var timeoutActivityOptions: TimeoutActivityOptions
    
    var body: some View
    {
        Slider(value: $timeoutActivityOptions.soundVolume, in: 0.0 ... 1.0, onEditingChanged:
        {
            _volume in
            
            timeoutActivityOptions.soundOnTimeout?.volume = timeoutActivityOptions.soundVolume
        })
    }
}

fileprivate struct SoundVolumeSliderBox: View
{
    var body: some View
    {
        HStack(alignment: .top)
        {
            Image(nsImage: NSImage(named: NSImage.touchBarVolumeDownTemplateName)!)
            
            SoundVolumeSlider()
        }
    }
}

struct TimeoutActivitySettingsView: View
{
    @EnvironmentObject private var timeoutActivityOptions: TimeoutActivityOptions
    private let sounds = ["Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero",
                          "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"]
    
    static fileprivate let soundMenuButtonWidth: CGFloat = 110.0
    static fileprivate let soundVolumeSliderBoxWidth: CGFloat = 110.0
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Toggle(isOn: $timeoutActivityOptions.showPopoverOnTimeout)
            {
                Text("Pop up on timeout")
            }
            
            /*
             * Using MenuButton instead of Picker allows us to distinguish between
             * the action/callback/onReceive function of "No sound" and that of all the sounds.
             */
            MenuButton(timeoutActivityOptions.soundMenuButtonName)
            {
                Button("No sound")
                {
                    timeoutActivityOptions.soundOnTimeout = nil
                    timeoutActivityOptions.soundMenuButtonName = "No sound"
                }
                
                ForEach(sounds, id: \.self)
                {
                    sound in
                    
                    Button(sound)
                    {
                        timeoutActivityOptions.soundOnTimeout = NSSound(named: sound)
                        timeoutActivityOptions.soundOnTimeout?.volume = timeoutActivityOptions.soundVolume
                        timeoutActivityOptions.soundMenuButtonName = sound
                    }
                }
            }
            .frame(width: TimeoutActivitySettingsView.soundMenuButtonWidth)
            
            SoundVolumeSliderBox()
            .frame(width: TimeoutActivitySettingsView.soundVolumeSliderBoxWidth)
        }
    }
}
