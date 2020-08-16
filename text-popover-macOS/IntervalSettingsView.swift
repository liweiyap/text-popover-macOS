//
//  IntervalSettingsView.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 08.08.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI
import Combine

final class IntervalMenuButtonNames: ObservableObject
{
    @Published var minutesMenuButtonName: String = "Minutes"
    @Published var hoursMenuButtonName: String = "Hours"
    
    func resetToDefault() -> Void
    {
        minutesMenuButtonName = "Minutes"
        hoursMenuButtonName = "Hours"
    }
}

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
    @EnvironmentObject var intervalMenuButtonNames: IntervalMenuButtonNames
    let name: String
    let value: Int
    @Binding var parentMenuButtonName: String
    
    var body: some View
    {
        Button(name)
        {
            self.timerWrapper.interval = self.value
            self.timerWrapper.counter = 0
            
            self.intervalMenuButtonNames.resetToDefault()
            self.parentMenuButtonName = self.name
        }
    }
}

struct IntervalMenuItemButtonArray: View
{
    @EnvironmentObject var timerWrapper: TimerWrapper
    let intervals: [IntervalHashable]
    
    @EnvironmentObject var intervalMenuButtonNames: IntervalMenuButtonNames
    @Binding var parentMenuButtonName: String
    
    var body: some View
    {
        ForEach(intervals, id: \.self)
        {
            interval in
            
            IntervalMenuItemButton(name: interval.name, value: interval.value,
                                   parentMenuButtonName: self.$parentMenuButtonName)
        }
    }
}

struct IntervalSettingsView: View
{
    @EnvironmentObject var timerWrapper: TimerWrapper
    @EnvironmentObject var intervalMenuButtonNames: IntervalMenuButtonNames
    
    static var intervalMenuButtonWidth: CGFloat = 100.0
    
    func getTime() -> TimerWrapper.Time
    {
        return timerWrapper.getTime()
    }
    
    var body: some View
    {
        VStack
        {
            Text("Time until next Expression: \(String(format: "%02d",self.getTime().hours)):\(String(format: "%02d",self.getTime().minutes)):\(String(format: "%02d",self.getTime().seconds))")
            
            MenuButton(intervalMenuButtonNames.minutesMenuButtonName)
            {
                IntervalMenuItemButtonArray(
                    intervals: MinutesInterval().getIntervals(),
                    parentMenuButtonName: $intervalMenuButtonNames.minutesMenuButtonName)
            }
            .frame(width: IntervalSettingsView.intervalMenuButtonWidth)
            
            MenuButton(intervalMenuButtonNames.hoursMenuButtonName)
            {
                IntervalMenuItemButtonArray(
                    intervals: HoursIntervalShort().getIntervals(),
                    parentMenuButtonName: $intervalMenuButtonNames.hoursMenuButtonName)
                
                Divider()
                
                IntervalMenuItemButtonArray(
                    intervals: HoursIntervalLong().getIntervals(),
                    parentMenuButtonName: $intervalMenuButtonNames.hoursMenuButtonName)
            }
            .frame(width: IntervalSettingsView.intervalMenuButtonWidth)
        }
    }
}
