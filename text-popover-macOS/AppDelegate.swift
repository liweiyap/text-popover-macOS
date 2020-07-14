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

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        let contentView = ContentView()
        
        popover.contentSize = NSSize(width: 400, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        statusItem.button?.title = "Text-PopOver"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover(_:))
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }

    @objc func togglePopover(_ sender: AnyObject?)
    {
        if let button = statusItem.button
        {
            if popover.isShown
            {
                popover.performClose(sender)
            }
            else
            {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}

