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
    let name: String
    let value: Int
}

protocol Interval
{
    func getIntervals() -> [IntervalHashable]
}

final class MinutesInterval: Interval
{
    let intervals =
        [
            IntervalHashable(name: "5 minutes", value: 5 * Int.secondsPerMinute),
            IntervalHashable(name: "10 minutes", value: 10 * Int.secondsPerMinute),
            IntervalHashable(name: "15 minutes", value: 15 * Int.secondsPerMinute),
            IntervalHashable(name: "20 minutes", value: 20 * Int.secondsPerMinute),
            IntervalHashable(name: "30 minutes", value: 30 * Int.secondsPerMinute),
            IntervalHashable(name: "45 minutes", value: 45 * Int.secondsPerMinute)
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
            IntervalHashable(name: "1 hour", value: 1 * Int.secondsPerHour),
            IntervalHashable(name: "2 hours", value: 2 * Int.secondsPerHour),
            IntervalHashable(name: "3 hours", value: 3 * Int.secondsPerHour),
            IntervalHashable(name: "4 hours", value: 4 * Int.secondsPerHour),
            IntervalHashable(name: "5 hours", value: 5 * Int.secondsPerHour),
            IntervalHashable(name: "6 hours", value: 6 * Int.secondsPerHour)
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
            IntervalHashable(name: "8 hours", value: 8 * Int.secondsPerHour),
            IntervalHashable(name: "12 hours", value: 12 * Int.secondsPerHour),
            IntervalHashable(name: "24 hours", value: 24 * Int.secondsPerHour)
        ]
    
    func getIntervals() -> [IntervalHashable]
    {
        return intervals
    }
}

struct IntervalMenuItemButton: View
{
    @EnvironmentObject var timerWrapper: TimerWrapper
    let name: String
    let value: Int
    
    var body: some View
    {
        Button(name)
        {
            self.timerWrapper.interval = self.value
            self.timerWrapper.counter = 0
        }
    }
}

struct IntervalMenuItemButtonArray: View
{
    @EnvironmentObject var timerWrapper: TimerWrapper
    let intervals: [IntervalHashable]
    
    var body: some View
    {
        ForEach(intervals, id: \.self)
        {
            interval in
            
            IntervalMenuItemButton(name: interval.name, value: interval.value)
            .environmentObject(self.timerWrapper)
        }
    }
}

struct IntervalSettingsView: View
{
    @EnvironmentObject var timerWrapper: TimerWrapper
    
    func getTime() -> TimerWrapper.Time
    {
        return timerWrapper.getTime()
    }
    
    var body: some View
    {
        VStack
        {
            Text("Time Remaining: \(String(format: "%02d",self.getTime().hours)):\(String(format: "%02d",self.getTime().minutes)):\(String(format: "%02d",self.getTime().seconds))")
            
            MenuButton("Minutes")
            {
                IntervalMenuItemButtonArray(intervals: MinutesInterval().getIntervals())
            }
            .frame(width: 100.0)
            
            MenuButton("Hours")
            {
                IntervalMenuItemButtonArray(intervals: HoursIntervalShort().getIntervals())
                
                Divider()
                
                IntervalMenuItemButtonArray(intervals: HoursIntervalLong().getIntervals())
            }
            .frame(width: 100.0)
        }
        .environmentObject(self.timerWrapper)
    }
}
