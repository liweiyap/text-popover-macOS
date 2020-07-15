//
//  AppDelegate.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 13.07.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    let statusItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    let popover = NSPopover()
    var eventMonitor: EventMonitor?

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        let contentView = ContentView()
        
        popover.contentSize = NSSize(width: 400, height: 400)
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        statusItem.button?.title = "Text-PopOver"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover(_:))
        
        eventMonitor = EventMonitor(
        mask: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown])
        {[weak self] event in
            if let popover = self?.popover
            {
                if popover.isShown
                {
                    popover.performClose(event)
                    self?.eventMonitor?.stop()
                }
            }
        }
        eventMonitor?.start()
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }

    @objc func togglePopover(_ sender: AnyObject?)
    {
        if popover.isShown
        {
            popover.performClose(sender)
            eventMonitor?.stop()
        }
        else
        {
            if let button = statusItem.button
            {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                eventMonitor?.start()
            }
        }
    }
}

