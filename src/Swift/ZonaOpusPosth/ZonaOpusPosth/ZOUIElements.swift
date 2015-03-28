//
//  ZOUIElements.swift
//  Zona Opus Posth
//
//  Created by Ales Tsurko on 21.03.15.
//  Copyright (c) 2015 Ales Tsurko. All rights reserved.
//
//

class ZOUIElements : NSObject {

    //// Drawing Methods

    class func drawKnob(#value: CGFloat) {
        //// General Declarations
        let context = unsafeBitCast(NSGraphicsContext.currentContext()!.graphicsPort, CGContext.self)

        //// Color Declarations
        let color = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.748)

        //// Variable Declarations
        let expression: CGFloat = -290 * value

        //// Bezier 2 Drawing
        NSGraphicsContext.saveGraphicsState()
        CGContextTranslateCTM(context, 55, 55)
        CGContextRotateCTM(context, (expression + 145) * CGFloat(M_PI) / 180)

        var bezier2Path = NSBezierPath()
        bezier2Path.moveToPoint(NSMakePoint(-6, 50))
        bezier2Path.curveToPoint(NSMakePoint(-6, 32.24), controlPoint1: NSMakePoint(-6, 32.76), controlPoint2: NSMakePoint(-6, 32.24))
        bezier2Path.lineToPoint(NSMakePoint(7, 32.24))
        bezier2Path.curveToPoint(NSMakePoint(7, 49.87), controlPoint1: NSMakePoint(7, 32.24), controlPoint2: NSMakePoint(7, 32.67))
        bezier2Path.curveToPoint(NSMakePoint(35.36, 35.66), controlPoint1: NSMakePoint(17.37, 48.41), controlPoint2: NSMakePoint(27.38, 43.67))
        bezier2Path.curveToPoint(NSMakePoint(35.36, -35.3), controlPoint1: NSMakePoint(54.88, 16.07), controlPoint2: NSMakePoint(54.88, -15.71))
        bezier2Path.curveToPoint(NSMakePoint(-35.36, -35.3), controlPoint1: NSMakePoint(15.83, -54.9), controlPoint2: NSMakePoint(-15.83, -54.9))
        bezier2Path.curveToPoint(NSMakePoint(-35.36, 35.66), controlPoint1: NSMakePoint(-54.88, -15.71), controlPoint2: NSMakePoint(-54.88, 16.07))
        bezier2Path.curveToPoint(NSMakePoint(-6, 50), controlPoint1: NSMakePoint(-27.12, 43.93), controlPoint2: NSMakePoint(-16.73, 48.71))
        bezier2Path.closePath()
        bezier2Path.moveToPoint(NSMakePoint(0, 38))
        bezier2Path.lineToPoint(NSMakePoint(1, 38))
        bezier2Path.lineToPoint(NSMakePoint(1, 48))
        bezier2Path.lineToPoint(NSMakePoint(0, 48))
        bezier2Path.lineToPoint(NSMakePoint(0, 38))
        bezier2Path.closePath()
        bezier2Path.lineJoinStyle = NSLineJoinStyle.RoundLineJoinStyle
        color.setStroke()
        bezier2Path.lineWidth = 3
        bezier2Path.stroke()

        NSGraphicsContext.restoreGraphicsState()
    }

    class func drawWaveformViewCursor(#cursorPosition: CGFloat, waveformArea: NSRect) {
        //// General Declarations
        let context = unsafeBitCast(NSGraphicsContext.currentContext()!.graphicsPort, CGContext.self)

        //// Color Declarations
        let color2 = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.5)

        //// Variable Declarations
        let linkCursorHeight: CGFloat = waveformArea.size.height / 110.0
        let cursorPositionToWaveformWidthLink: CGFloat = cursorPosition * waveformArea.size.width

        //// area Drawing


        //// Bezier Drawing
        NSGraphicsContext.saveGraphicsState()
        CGContextTranslateCTM(context, cursorPositionToWaveformWidthLink, 0.5)
        CGContextScaleCTM(context, 1, linkCursorHeight)

        var bezierPath = NSBezierPath()
        bezierPath.moveToPoint(NSMakePoint(0, 0))
        bezierPath.lineToPoint(NSMakePoint(0, 109))
        color2.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.stroke()

        NSGraphicsContext.restoreGraphicsState()
    }

}
