//
//  EventMonitor.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 15.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import Cocoa

open class EventMonitor
{
    
    fileprivate var monitor: AnyObject?
    fileprivate let mask: NSEvent.EventTypeMask
    fileprivate let handler: (NSEvent?) -> ()
    
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> ())
    {
        self.mask = mask
        self.handler = handler
    }
    
    deinit
    {
        stop()
    }
    
    open func start()
    {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject?
    }
    
    open func stop()
    {
        if monitor != nil
        {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
