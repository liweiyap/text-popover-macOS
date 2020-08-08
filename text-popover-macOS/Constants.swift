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

enum MinutesInterval: String, CaseIterable
{
    case min05 = "5 Minuten"
    case min10 = "10 Minuten"
    case min15 = "15 Minuten"
    case min20 = "20 Minuten"
    case min30 = "30 Minuten"
    case min45 = "45 Minuten"

    func getInterval() -> Double
    {
        switch self
        {
        case .min05:
            return 5.0 * Double(Int.secondsPerMinute)
        case .min10:
            return 10.0 * Double(Int.secondsPerMinute)
        case .min15:
            return 15.0 * Double(Int.secondsPerMinute)
        case .min20:
            return 20.0 * Double(Int.secondsPerMinute)
        case .min30:
            return 30.0 * Double(Int.secondsPerMinute)
        case .min45:
            return 45.0 * Double(Int.secondsPerMinute)
        }
    }
}

enum HoursIntervalShort: String, CaseIterable
{
    case hr01 = "1 Stunde"
    case hr02 = "2 Stunden"
    case hr03 = "3 Stunden"
    case hr04 = "4 Stunden"
    case hr05 = "5 Stunden"
    case hr06 = "6 Stunden"

    func getInterval() -> Double
    {
        switch self
        {
        case .hr01:
            return 1.0 * Double(Int.secondsPerHour)
        case .hr02:
            return 2.0 * Double(Int.secondsPerHour)
        case .hr03:
            return 3.0 * Double(Int.secondsPerHour)
        case .hr04:
            return 4.0 * Double(Int.secondsPerHour)
        case .hr05:
            return 5.0 * Double(Int.secondsPerHour)
        case .hr06:
            return 6.0 * Double(Int.secondsPerHour)
        }
    }
}

enum HoursIntervalLong: String, CaseIterable
{
    case hr08 = "8 Stunden"
    case hr12 = "12 Stunden"
    case hr24 = "24 Stunden"

    func getInterval() -> Double
    {
        switch self
        {
        case .hr08:
            return 8.0 * Double(Int.secondsPerHour)
        case .hr12:
            return 12.0 * Double(Int.secondsPerHour)
        case .hr24:
            return 24.0 * Double(Int.secondsPerHour)
        }
    }
}
