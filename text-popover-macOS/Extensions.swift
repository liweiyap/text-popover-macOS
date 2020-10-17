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
    static let royalBlue = Color(red: 71/255, green: 94/255, blue: 213/255, opacity: 1)
}

extension NSColor
{
    static let sunsetOrange = NSColor(red: 255/255, green: 96/255, blue: 92/255, alpha: 1)
    static let pastelOrange = NSColor(red: 255/255, green: 189/255, blue: 68/255, alpha: 1)
    static let malachite = NSColor(red: 0, green: 202/255, blue: 78/255, alpha: 1)
    static let royalBlue = NSColor(red: 71/255, green: 94/255, blue: 213/255, alpha: 1)
}

/*
 * Helper struct to access the NSView of a View from SwiftUI
 * Called in onNSView()
 */
struct NSViewAccessor<Content>: NSViewRepresentable where Content: View
{
    var onNSView: (NSView) -> Void
    var viewBuilder: () -> Content

    init(onNSViewAdded: @escaping (NSView) -> Void, @ViewBuilder viewBuilder: @escaping () -> Content)
    {
        self.onNSView = onNSViewAdded
        self.viewBuilder = viewBuilder
    }

    func makeNSView(context: Context) -> NSViewAccessorHosting<Content>
    {
        return NSViewAccessorHosting(onNSView: onNSView, rootView: self.viewBuilder())
    }

    func updateNSView(_ nsView: NSViewAccessorHosting<Content>, context: Context)
    {
        nsView.rootView = self.viewBuilder()
    }
}

/*
 * Helper class to access the NSView of a View from SwiftUI
 * Required in NSViewAccessor
 */
class NSViewAccessorHosting<Content>: NSHostingView<Content> where Content: View
{
    var onNSView: ((NSView) -> Void)

    init(onNSView: @escaping (NSView) -> Void, rootView: Content)
    {
        self.onNSView = onNSView
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    required init(rootView: Content)
    {
        fatalError("init(rootView:) has not been implemented")
    }

    override func didAddSubview(_ subview: NSView)
    {
        super.didAddSubview(subview)
        onNSView(subview)
    }
}

/*
 * Access the NSView of a View from SwiftUI
 */
extension View
{
    func onNSView(added: @escaping (NSView) -> Void) -> some View
    {
        NSViewAccessor(onNSViewAdded: added)
        {
            self
        }
    }
}
