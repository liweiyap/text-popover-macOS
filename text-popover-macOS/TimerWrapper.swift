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
    @Published var timer = Timer.publish(every: TimeInterval(Int.secondsPerMinute),
                                         tolerance: 0.5, on: .main, in: .common).autoconnect()
    
    @Published var interval = 24 * Int.minutesPerHour
    
    @Published var timeRemaining = 24 * Int.minutesPerHour
    
    struct Time
    {
        var hours: Int
        var minutes: Int
        
        init(_ hrs: Int, _ mins: Int)
        {
            hours = hrs
            minutes = mins
        }
    }
    
    func getTimeRemaining() -> Time
    {
        let hoursRemaining: Int = timeRemaining / Int.minutesPerHour
        let minutesRemaining: Int = timeRemaining % Int.minutesPerHour
        
        return Time(hoursRemaining, minutesRemaining)
    }
}
