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
            IntervalHashable(name: "5 minutes", value: 5),
            IntervalHashable(name: "10 minutes", value: 10),
            IntervalHashable(name: "15 minutes", value: 15),
            IntervalHashable(name: "20 minutes", value: 20),
            IntervalHashable(name: "30 minutes", value: 30),
            IntervalHashable(name: "45 minutes", value: 45)
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
            IntervalHashable(name: "1 hour", value: 1 * Int.minutesPerHour),
            IntervalHashable(name: "2 hours", value: 2 * Int.minutesPerHour),
            IntervalHashable(name: "3 hours", value: 3 * Int.minutesPerHour),
            IntervalHashable(name: "4 hours", value: 4 * Int.minutesPerHour),
            IntervalHashable(name: "5 hours", value: 5 * Int.minutesPerHour),
            IntervalHashable(name: "6 hours", value: 6 * Int.minutesPerHour)
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
            IntervalHashable(name: "8 hours", value: 8 * Int.minutesPerHour),
            IntervalHashable(name: "12 hours", value: 12 * Int.minutesPerHour),
            IntervalHashable(name: "24 hours", value: 24 * Int.minutesPerHour)
        ]
    
    func getIntervals() -> [IntervalHashable]
    {
        return intervals
    }
}

struct IntervalMenuItemButton: View
{
    @EnvironmentObject var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject var intervalMenuButtonNames: IntervalMenuButtonNames
    let name: String
    let value: Int
    @Binding var parentMenuButtonName: String
    
    var body: some View
    {
        Button(name)
        {
            /*
             * Current interval is already in progress. If same interval value is re-selected,
             * then don't stop current interval.
             */
            if countdownTimerWrapper.interval != value
            {
                countdownTimerWrapper.interval = value
                countdownTimerWrapper.timeRemaining = value
                intervalMenuButtonNames.resetToDefault()
            }
            
            /*
             * Don't include the following in the IF statement, because we want to account for
             * the edge case, which occurs at the very start or if no interval has been chosen
             * yet from the menu buttons. Here, the interval that is active has some numerical
             * value, but the current [minutes|hours]MenuButtonName is equal to its default
             * "Minutes"|"Hours" rather than this numerical value, so we want to set it to this
             * numerical value.
             */
            parentMenuButtonName = name
        }
    }
}

struct IntervalMenuItemButtonArray: View
{
    let intervals: [IntervalHashable]
    @Binding var parentMenuButtonName: String
    
    var body: some View
    {
        ForEach(intervals, id: \.self)
        {
            interval in
            
            IntervalMenuItemButton(name: interval.name, value: interval.value,
                                   parentMenuButtonName: $parentMenuButtonName)
        }
    }
}

struct IntervalSettingsView: View
{
    @EnvironmentObject var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject var intervalMenuButtonNames: IntervalMenuButtonNames
    
    static var intervalMenuButtonWidth: CGFloat = 110.0
    
    func getTimeRemaining() -> CountdownTimerWrapper.Time
    {
        return countdownTimerWrapper.getTimeRemaining()
    }
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Text("\(String(format:"%02d",getTimeRemaining().hours)):\(String(format:"%02d",getTimeRemaining().minutes)) until next Expression")
            
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
