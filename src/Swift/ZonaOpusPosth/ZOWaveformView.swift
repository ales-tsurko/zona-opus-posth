//
//  ZOWaveformView.swift
//  ZonaOpusPosth
//
//  Created by Ales Tsurko on 20.03.15.
//  Copyright (c) 2015 Ales Tsurko. All rights reserved.
//

class Cursor: NSView {
    
    var doubleClickedPosition: CGFloat?
    var position: CGFloat = 0 {
        didSet(value) {
            self.display()
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        ZOUIElements.drawWaveformViewCursor(cursorPosition: self.position, waveformArea: dirtyRect)
    }
}

class ZOWaveformView: EZAudioPlot {
    
    let cursor = Cursor()
    override var mouseDownCanMoveWindow: Bool {
        get {
            return false
        }
    }
    override func awakeFromNib() {
        cursor.frame = self.bounds
        self.addSubview(self.cursor)
    }
    
    override func acceptsFirstMouse(theEvent: NSEvent) -> Bool {
        return true
    }
    
    func drawWaveform(fileName: String, fileType: String, gain: Float) {
        
        let filePathString = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)!
        let filePathURL = NSURL(string: filePathString)
        let audioFile = EZAudioFile(URL: filePathURL)
        
        let bgColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.3)
        let color = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.5)
        
        self.plotType = EZPlotType.Buffer
        self.shouldFill = true
        self.shouldMirror = true
        self.gain = gain
        self.backgroundColor = bgColor
        self.color = color
        
        audioFile.getWaveformDataWithCompletionBlock({(waveformData, length)
            in self.updateBuffer(waveformData, withBufferSize: length)
        })
    }
    
    override func mouseUp(theEvent: NSEvent) {
        var eventLocation: NSPoint
        var localPoint: NSPoint
        var clickCount = theEvent.clickCount
        
        if(clickCount == 2) {
            eventLocation = theEvent.locationInWindow
            localPoint = self.convertPoint(eventLocation, fromView: nil)
            cursor.position = localPoint.x / self.frame.width
            cursor.doubleClickedPosition = localPoint.x / self.frame.width
        }
    }
}