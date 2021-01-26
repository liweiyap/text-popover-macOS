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
    
    let databaseManagerWrapper = DatabaseManagerWrapper()
    let countdownTimerWrapper = CountdownTimerWrapper()
    let additionalToggableTextOptions = AdditionalToggableTextOptions()
    let timeoutActivityOptions = TimeoutActivityOptions()
    let backgroundOptions = BackgroundOptions()
    let intervalMenuButtonNames = IntervalMenuButtonNames()
    
    static var selfInstance: AppDelegate?
    
    override init()
    {
        super.init()
        AppDelegate.selfInstance = self
    }

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        /*
         * Allows keyDown events to be detected
         * https://stackoverflow.com/questions/49716420/adding-a-global-monitor-with-nseventmaskkeydown-mask-does-not-trigger
         */
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        if !accessEnabled
        {
            print("Access not enabled. Check System Preferences > Security & Privacy.")
        }
        
        let contentView = ContentView()
            .environmentObject(databaseManagerWrapper)
            .environmentObject(countdownTimerWrapper)
            .environmentObject(additionalToggableTextOptions)
            .environmentObject(timeoutActivityOptions)
            .environmentObject(backgroundOptions)
            .environmentObject(intervalMenuButtonNames)
        
        popover.contentSize = NSSize(width: 400, height: 200)
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        statusItem.button?.title = "Text-PopOver"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover(_:))
        
        eventMonitor = EventMonitor(mask:
            [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown,
             NSEvent.EventTypeMask.otherMouseDown, NSEvent.EventTypeMask.keyDown,
             NSEvent.EventTypeMask.swipe])
        {
            [weak self] event in
            
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
