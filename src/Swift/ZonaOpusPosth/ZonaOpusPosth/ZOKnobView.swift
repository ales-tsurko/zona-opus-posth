//
//  ZOKnobView.swift
//  ZonaOpusPosth
//
//  Created by Ales Tsurko on 07.03.15.
//  Copyright (c) 2015 Ales Tsurko. All rights reserved.
//

import Cocoa

class ZOKnobView: NSView {
    
    var knobValue: CGFloat = 0
    override var mouseDownCanMoveWindow: Bool {
         get {
            return false
            }
        }
    
    override func acceptsFirstMouse(theEvent: NSEvent) -> Bool {
        return true
    }

    override func drawRect(dirtyRect: NSRect) {
        ZOUIElements.drawKnob(value: self.knobValue);
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        var value: CGFloat
        var precision: CGFloat = 200
        
        value = (theEvent.deltaY * -1) / precision + self.knobValue
        
        if (value >= 0 && value <= 1) {
            self.knobValue = value
        }
        
        self.display()
    }
    
}
