//
//  TimerWrapper.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 21.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import Foundation

final class TimerWrapper: ObservableObject
{
    @Published var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    @Published var interval = 24 * Int.secondsPerHour
    
    @Published var counter = 0
    
    struct Time
    {
        var hours: Int
        var minutes: Int
        var seconds: Int
        
        init(_ hrs: Int, _ mins: Int, _ secs: Int)
        {
            hours = hrs
            minutes = mins
            seconds = secs
        }
    }
    
    func getTime() -> Time
    {
        var secondsRemaining: Int = interval - counter
        let hoursRemaining: Int = secondsRemaining / Int.secondsPerHour
        let minutesRemaining: Int = (secondsRemaining / Int.secondsPerMinute) % Int.secondsPerMinute
        secondsRemaining %= Int.secondsPerMinute
        
        return Time(hoursRemaining, minutesRemaining, secondsRemaining)
    }
}
