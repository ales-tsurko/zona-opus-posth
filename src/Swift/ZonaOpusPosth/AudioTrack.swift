//
//  AudioTrack.swift
//  ZonaOpusPosth
//
//  Created by Ales Tsurko on 25.03.15.
//  Copyright (c) 2015 Ales Tsurko. All rights reserved.
//

import AVFoundation

class AudioTrack: AKInstrument {
    var playingPosition = AKInstrumentProperty(value: 0)
    var rate = AKInstrumentProperty(value: 1)
    var transpose = AKInstrumentProperty(value: 1)
    var amplitude = AKInstrumentProperty(value: 0, minimum: 0, maximum: 1)
    
    override init() {
        super.init()
    }
    
    convenience init(fileName: String, fileType: String) {
        self.init()
        
        addProperty(playingPosition)
        addProperty(rate)
        addProperty(transpose)
        addProperty(amplitude)
        
        let fileSR: Float = 44100
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)! as String
        let avAudioFile = AVAudioFile(forReading: NSURL(fileURLWithPath: filePath), error: nil)
        let sampleSize = avAudioFile.length
        let fileLengthInSeconds = Float(sampleSize)/fileSR
        
        let note = Playback()
        
        addNoteProperty(note.startTime)
        
        let player = AKFileInput(filename: filePath)
        
        player.startTime = note.startTime.scaledBy(akp(fileLengthInSeconds))
        player.speed = rate.scaledBy(transpose)
        
        connect(player)
        
        connect(AKAudioOutput(stereoAudioSource: player.scaledBy(amplitude)))
        
        assignOutput(playingPosition, to: akp(64/(Float(sampleSize))).scaledBy(rate).scaledBy(transpose))
    }
}

class Playback: AKNote {
    var startTime = AKNoteProperty(value: 0, minimum: 0, maximum: 100000000)
    
    override init() {
        super.init()
        
        addProperty(startTime)
    }
    
    convenience init(startTime: Float) {
        self.init()
        self.startTime.setValue(startTime)
    }
}
