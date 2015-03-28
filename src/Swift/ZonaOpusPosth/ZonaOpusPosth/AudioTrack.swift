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
    var setPosition = AKInstrumentProperty(value: 0)
    var rate = AKInstrumentProperty(value: 1)
    var amplitude = AKInstrumentProperty(value: 0, minimum: 0, maximum: 1)
    
    override init() {
        super.init()
    }
    
    convenience init(fileName: String, fileType: String) {
        self.init()
        
        addProperty(playingPosition)
        addProperty(setPosition)
        addProperty(rate)
        addProperty(amplitude)
        
        let fileSR: Float = 44100
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)! as String
        let avAudioFile = AVAudioFile(forReading: NSURL(fileURLWithPath: filePath), error: nil)
        let sampleSize = avAudioFile.length
        
        let player = AKFileInput(filename: filePath)
        
        player.speed = rate
        
        connect(player)
        
        player.scaledBy(amplitude)
        
        let phasorNormalRate = akp(1/(Float(sampleSize)/fileSR))
        
        let phasor = AKPhasor(frequency: phasorNormalRate.scaledBy(rate), phase: 0.ak)
        
        connect(phasor)
        
        connect(AKAssignment(output: playingPosition, input: phasor))
        
        connect(AKAudioOutput(stereoAudioSource: player))
    }
}
