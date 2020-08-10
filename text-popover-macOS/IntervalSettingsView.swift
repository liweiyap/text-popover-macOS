//
//  IntervalSettingsView.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 08.08.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI
import Combine

struct IntervalHashable: Hashable
{
    var name: String
    var value: Double
}

protocol Interval
{
    func getIntervals() -> [IntervalHashable]
}

final class MinutesInterval: Interval
{
    let intervals =
        [
            IntervalHashable(name: "5 minutes", value: 5.0 * Double(Int.secondsPerMinute)),
            IntervalHashable(name: "10 minutes", value: 10.0 * Double(Int.secondsPerMinute)),
            IntervalHashable(name: "15 minutes", value: 15.0 * Double(Int.secondsPerMinute)),
            IntervalHashable(name: "20 minutes", value: 20.0 * Double(Int.secondsPerMinute)),
            IntervalHashable(name: "30 minutes", value: 30.0 * Double(Int.secondsPerMinute)),
            IntervalHashable(name: "45 minutes", value: 45.0 * Double(Int.secondsPerMinute))
        ]
    
    func getIntervals() -> [IntervalHashable]
    {
        return intervals
    }
}

final class HoursIntervalShort: Interval
{
    let intervals =
        [
            IntervalHashable(name: "1 hour", value: 1.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "2 hours", value: 2.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "3 hours", value: 3.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "4 hours", value: 4.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "5 hours", value: 5.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "6 hours", value: 6.0 * Double(Int.secondsPerHour))
        ]
    
    func getIntervals() -> [IntervalHashable]
    {
        return intervals
    }
}

final class HoursIntervalLong: Interval
{
    let intervals =
        [
            IntervalHashable(name: "8 hours", value: 8.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "12 hours", value: 12.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "24 hours", value: 24.0 * Double(Int.secondsPerHour))
        ]
    
    func getIntervals() -> [IntervalHashable]
    {
        return intervals
    }
}

struct IntervalMenuItemButton: View
{
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let window: NSWindow?
    let name: String
    let value: Double
    
    var body: some View
    {
        Button(name)
        {
            self.timer = Timer.publish(every: self.value, on: .main, in: .common).autoconnect()
            self.window!.close()
        }
    }
}

struct IntervalMenuItemButtonArray: View
{
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let window: NSWindow?
    let intervals: [IntervalHashable]
    
    var body: some View
    {
        ForEach(intervals, id: \.self)
        {
            interval in
            
            IntervalMenuItemButton(timer: self.$timer, window: self.window,
                                   name: interval.name, value: interval.value)
        }
    }
}

struct IntervalSettingsView: View
{
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let window: NSWindow?
    
    var body: some View
    {
        VStack
        {
            MenuButton("Minutes")
            {
                IntervalMenuItemButtonArray(timer: self.$timer, window: self.window,
                                            intervals: MinutesInterval().getIntervals())
            }
            .frame(width: 100.0)
            
            MenuButton("Hours")
            {
                IntervalMenuItemButtonArray(timer: self.$timer, window: self.window,
                                            intervals: HoursIntervalShort().getIntervals())
                
                Divider()
                
                IntervalMenuItemButtonArray(timer: self.$timer, window: self.window,
                                            intervals: HoursIntervalLong().getIntervals())
            }
            .frame(width: 100.0)
        }
    }
}
