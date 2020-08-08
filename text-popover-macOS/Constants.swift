//
//  Constants.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 28.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import Foundation

extension Int
{    
    static var secondsPerMinute = 60
    static var secondsPerHour = 3600
}

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
            IntervalHashable(name: "5 Minuten", value: 5.0 * Double(Int.secondsPerMinute)),
            IntervalHashable(name: "10 Minuten", value: 10.0 * Double(Int.secondsPerMinute)),
            IntervalHashable(name: "15 Minuten", value: 15.0 * Double(Int.secondsPerMinute)),
            IntervalHashable(name: "20 Minuten", value: 20.0 * Double(Int.secondsPerMinute)),
            IntervalHashable(name: "30 Minuten", value: 30.0 * Double(Int.secondsPerMinute)),
            IntervalHashable(name: "45 Minuten", value: 45.0 * Double(Int.secondsPerMinute))
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
            IntervalHashable(name: "1 Stunde", value: 1.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "2 Stunden", value: 2.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "3 Stunden", value: 3.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "4 Stunden", value: 4.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "5 Stunden", value: 5.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "6 Stunden", value: 6.0 * Double(Int.secondsPerHour))
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
            IntervalHashable(name: "8 Stunden", value: 8.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "12 Stunden", value: 12.0 * Double(Int.secondsPerHour)),
            IntervalHashable(name: "24 Stunden", value: 24.0 * Double(Int.secondsPerHour))
        ]
    
    func getIntervals() -> [IntervalHashable]
    {
        return intervals
    }
}
