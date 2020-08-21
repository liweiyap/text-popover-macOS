//
//  Extensions.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 21.08.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI

extension Int
{
    static let secondsPerMinute = 60
    static let secondsPerHour = 3600
    static let minutesPerHour = 60
}

extension NSImage
{
    func resize(width: Int, height: Int) -> NSImage
    {
        let destSize = NSMakeSize(CGFloat(width), CGFloat(height))
        guard let copiedImage = self.copy() as? NSImage else { return self }
    
        copiedImage.lockFocus()
        copiedImage.draw(
            in: NSMakeRect(0, 0, destSize.width, destSize.height),
            from: NSMakeRect(0, 0, copiedImage.size.width, copiedImage.size.height),
            operation: NSCompositingOperation.sourceAtop,
            fraction: CGFloat(1))
        copiedImage.unlockFocus()
    
        copiedImage.size = destSize
        return copiedImage
    }

    func tint(colour: NSColor) -> NSImage
    {
        guard isTemplate else { return self }
        guard let copiedImage = self.copy() as? NSImage else { return self }

        copiedImage.lockFocus()
        colour.set()
        let imageBounds = NSMakeRect(0, 0, copiedImage.size.width, copiedImage.size.height)
        imageBounds.fill(using: .sourceAtop)
        copiedImage.unlockFocus()

        copiedImage.isTemplate = false
        return copiedImage
    }
}
