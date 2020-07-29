//
//  TimerWrapper.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 21.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import Foundation
import Combine

final class TimerWrapper: ObservableObject
{
    let willChange = PassthroughSubject<TimerWrapper, Never>()
    @Published var timer: Timer!
    var timerInterval: Double = TimeInterval(24.hours)

    func start(withTimeInterval interval: Double) -> Void
    {
        timer?.invalidate()
        
        timerInterval = interval
        timer = Timer
                .scheduledTimer(withTimeInterval: interval, repeats: true)
                {
                    _ in
                    
                    self.willChange.send(self)
                }
    }
    
    func start() -> Void
    {
        start(withTimeInterval: timerInterval)
    }
}
