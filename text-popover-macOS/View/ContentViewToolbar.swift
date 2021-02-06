//
//  ContentViewToolbar.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 06.09.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI

fileprivate struct ElaborationButton: View
{
    @Binding var elaborationIsViewed: Bool
    
    static let ElaborationButtonDimensions: CGFloat = 20.0
    
    var body: some View
    {
        Button(action: {
            elaborationIsViewed.toggle()
        })
        {
            Image(nsImage: NSImage(named: NSImage.infoName)!
                .resized(to: NSSize(width: ElaborationButton.ElaborationButtonDimensions,
                                    height: ElaborationButton.ElaborationButtonDimensions))!)
            .renderingMode(.original)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

fileprivate struct BackButton: View
{
    @Binding var elaborationIsViewed: Bool
    
    static let BackButtonDimensions: CGFloat = 18.0
    
    var body: some View
    {
        Button(action: {
            elaborationIsViewed.toggle()
        })
        {
            Image(nsImage: NSImage(named: NSImage.invalidDataFreestandingTemplateName)!
                .tint(colour: NSColor.royalBlue)
                .resized(to: NSSize(width: BackButton.BackButtonDimensions,
                                    height: BackButton.BackButtonDimensions))!)
            .renderingMode(.original)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.white)
        .clipShape(Circle())
    }
}

fileprivate struct CloseButtonStyle: ButtonStyle
{
    @Binding var isHovering: Bool
    
    static let CloseButtonDimensions: CGFloat = 12.0
    static let CloseButtonColour = NSColor.sunsetOrange
    
    func makeBody(configuration: Configuration) -> some View
    {
        ZStack
        {
            configuration.label
                .frame(width: CloseButtonStyle.CloseButtonDimensions,
                       height: CloseButtonStyle.CloseButtonDimensions)
                .background(Color(CloseButtonStyle.CloseButtonColour))
                .clipShape(Circle())
        }
        .onHover
        {
            hover in

            isHovering = hover
        }
        .overlay(HStack{
            if isHovering
            {
                Image(nsImage: NSImage(named: NSImage.stopProgressTemplateName)!
                    .resized(to: NSSize(width: CloseButtonStyle.CloseButtonDimensions / 2,
                                        height: CloseButtonStyle.CloseButtonDimensions / 2))!)
            }
        })
    }
}

fileprivate struct CloseButton: View
{
    @State private var isHovering: Bool = false
    
    var body: some View
    {
        Button(action: {
            NSApp.terminate(self)
        })
        {
            /*
             * For some reason, when `Text("×")` is used, there is some vspace above the ×?
             */
            Image(nsImage: NSImage(named: NSImage.stopProgressTemplateName)!
                .tint(colour: CloseButtonStyle.CloseButtonColour)
                .resized(to: NSSize(width: CloseButtonStyle.CloseButtonDimensions / 2,
                                    height: CloseButtonStyle.CloseButtonDimensions / 2))!)
        }
        .buttonStyle(CloseButtonStyle(isHovering: $isHovering))
    }
}

struct ContentViewToolbar: View
{
    @EnvironmentObject private var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject private var additionalToggableTextOptions: AdditionalToggableTextOptions
    
    @Binding var elaborationIsViewed: Bool
    
    private func getTimeRemaining() -> CountdownTimerWrapper.Time
    {
        return countdownTimerWrapper.getTimeRemaining()
    }
    
    var body: some View
    {
        HStack(alignment: .center)
        {
            CloseButton()
            
            if additionalToggableTextOptions.displayElaboration
            {
                if elaborationIsViewed
                {
                    BackButton(elaborationIsViewed: $elaborationIsViewed)
                }
                else
                {
                    ElaborationButton(elaborationIsViewed: $elaborationIsViewed)
                }
            }
            
            Spacer()
            
            Text("\(String(format:"%02d", getTimeRemaining().hours)):" +
                 "\(String(format:"%02d", getTimeRemaining().minutes))")

            SettingsButton()
        }
    }
}
