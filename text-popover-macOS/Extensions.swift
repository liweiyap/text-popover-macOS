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
    func resized(to newSize: NSSize) -> NSImage?
    {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)
        {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height),
                 from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()

            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }

        return nil
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

extension Color
{
    static let sunsetOrange = Color(red: 255/255, green: 96/255, blue: 92/255, opacity: 1)
    static let pastelOrange = Color(red: 255/255, green: 189/255, blue: 68/255, opacity: 1)
    static let malachite = Color(red: 0, green: 202/255, blue: 78/255, opacity: 1)
}

extension NSColor
{
    static let sunsetOrange = NSColor(red: 255/255, green: 96/255, blue: 92/255, alpha: 1)
    static let pastelOrange = NSColor(red: 255/255, green: 189/255, blue: 68/255, alpha: 1)
    static let malachite = NSColor(red: 0, green: 202/255, blue: 78/255, alpha: 1)
}
