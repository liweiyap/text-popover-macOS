//
//  CountdownTimerWrapper.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 19.08.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import Foundation
import Combine

final class CountdownTimerWrapper: ObservableObject
{
    /*
     * From the documentation: "A general rule, set the tolerance to at least 10% of the interval, for a repeating timer."
     * https://developer.apple.com/documentation/foundation/timer#1667624
     */
    @Published var timer = Timer.publish(every: TimeInterval(Int.secondsPerMinute),
                                         tolerance: TimeInterval(Int.secondsPerMinute / 10),
                                         on: .main, in: .common).autoconnect()
    
    @Published var interval = 24 * Int.minutesPerHour
    
    @Published var timeRemaining = 24 * Int.minutesPerHour
    
    let intervalExceededDuringSleep = PassthroughSubject<Void, Never>()
    
    func notifyIntervalExceededDuringSleep() -> Void
    {
        intervalExceededDuringSleep.send()
    }
    
    func checkIfIntervalExceededDuringSleep(timeSleptInMinutes: Int) -> Void
    {
        assert(timeSleptInMinutes >= 0, "Time slept cannot be negative")
        
        if timeRemaining - timeSleptInMinutes <= 0
        {
            let timeSleptModuloInterval = timeSleptInMinutes % interval
            if timeRemaining - timeSleptModuloInterval <= 0
            {
                timeRemaining = interval + (timeRemaining - timeSleptModuloInterval)
                
                assert((timeRemaining >= 0) && (timeRemaining <= interval),
                       "Error in calculations: time remaining is now greater than maximum interval.")
            }
            else
            {
                timeRemaining -= timeSleptModuloInterval
            }
            
            notifyIntervalExceededDuringSleep()
        }
        else
        {
            timeRemaining -= timeSleptInMinutes
        }
    }
    
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
    
    func formatTimeRemaining() -> Time
    {
        let hoursRemaining: Int = timeRemaining / Int.minutesPerHour
        let minutesRemaining: Int = timeRemaining % Int.minutesPerHour
        
        return Time(hoursRemaining, minutesRemaining)
    }
}
