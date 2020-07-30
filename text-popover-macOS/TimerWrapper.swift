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
    @Published var timer = Timer.publish(every: TimeInterval(24 * Int.secondsPerHour), on: .main, in: .common).autoconnect()
}
