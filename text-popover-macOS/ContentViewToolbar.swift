//
//  ContentViewToolbar.swift
//  text-popover-macOS
//
//  Created by Li-Wei Yap on 06.09.20.
//  Copyright © 2020 Li-Wei Yap. All rights reserved.
//

import SwiftUI

struct ElaborationButton: View
{
    @Binding var elaborationIsViewed: Bool
    
    static var ElaborationButtonDimensions: CGFloat = 20.0
    
    var body: some View
    {
        Button(action: {
            self.elaborationIsViewed.toggle()
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

struct BackButton: View
{
    @Binding var elaborationIsViewed: Bool
    
    static var BackButtonDimensions: CGFloat = 18.0
    
    var body: some View
    {
        Button(action: {
            self.elaborationIsViewed.toggle()
        })
        {
            Image(nsImage: NSImage(named: NSImage.invalidDataFreestandingTemplateName)!
                .resized(to: NSSize(width: BackButton.BackButtonDimensions,
                                    height: BackButton.BackButtonDimensions))!)
            .renderingMode(.original)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CloseButtonStyle: ButtonStyle
{
    @Binding var isHovering: Bool
    
    static var CloseButtonDimensions: CGFloat = 12.0
    static var CloseButtonColour = NSColor.sunsetOrange
    
    func makeBody(configuration: Self.Configuration) -> some View
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

            self.isHovering = hover
        }
        .overlay(HStack{
            if self.isHovering
            {
                Image(nsImage: NSImage(named: NSImage.stopProgressTemplateName)!
                    .resized(to: NSSize(width: CloseButtonStyle.CloseButtonDimensions / 2,
                                        height: CloseButtonStyle.CloseButtonDimensions / 2))!)
            }
        })
    }
}

struct CloseButton: View
{
    @State var isHovering: Bool = false
    
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
    @EnvironmentObject var countdownTimerWrapper: CountdownTimerWrapper
    @EnvironmentObject var additionalToggableTextOptions: AdditionalToggableTextOptions
    let intervalMenuButtonNames = IntervalMenuButtonNames()
    
    @Binding var elaborationIsViewed: Bool
    
    func getTimeRemaining() -> CountdownTimerWrapper.Time
    {
        return countdownTimerWrapper.getTimeRemaining()
    }
    
    var body: some View
    {
        HStack(alignment: .center)
        {
            /*
             * Manually adjust spacing, because, for some reason,
             * ElaborationButton by default lies more rightward than BackButton.
             */
            CloseButton()
            
            if additionalToggableTextOptions.displayElaboration
            {
                if elaborationIsViewed
                {
                    BackButton(elaborationIsViewed: self.$elaborationIsViewed)
                }
                else
                {
                    ElaborationButton(elaborationIsViewed: self.$elaborationIsViewed)
                }
            }
            
            Spacer()
            
            Text("\(String(format:"%02d",getTimeRemaining().hours)):\(String(format:"%02d",getTimeRemaining().minutes))")

            SettingsButton()
            .environmentObject(self.intervalMenuButtonNames)
        }
    }
}
