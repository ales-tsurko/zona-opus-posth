//
//  IgraVodi.swift
//  ZonaOpusPosth
//
//  Created by Ales Tsurko on 12.03.15.
//  Copyright (c) 2015 Ales Tsurko. All rights reserved.
//

class IgraVodiSynth: AKInstrument {
   
    var amplitude = AKInstrumentProperty(value: 0, minimum: 0, maximum: 1)
    var transpose = AKInstrumentProperty(value: 1, minimum: 0, maximum: 11)
    
    override init() {
        super.init()
    }
    
    convenience init(rate: Float) {
        self.init()
        
        addProperty(amplitude)
        addProperty(transpose)
        
        let filePath = NSBundle.mainBundle().pathForResource("igra_vodi", ofType: "wav")! as String
        let fileSR: Float = 44100
        
        let soundFileLeftChannel = AKSoundFile(asMonoFromLeftChannelOfStereoFile: filePath)
        let soundFileRightChannel = AKSoundFile(asMonoFromRightChannelOfStereoFile: filePath)
        
        soundFileLeftChannel.size = 2_097_152
        soundFileRightChannel.size = 2_097_152
        
        addFunctionTable(soundFileLeftChannel)
        addFunctionTable(soundFileRightChannel)
        
        let window = AKWindow(type: AKWindowTableType.Hanning)
        window.size = 512
        
        addFunctionTable(window)
        
        let dur = 1.ak
        let avgDur = 0.9.ak
        let freqVar = 0.ak
        let freq = ((fileSR / 2_097_152) * rate).ak
        let ampMod = 0.ak
        let density = 7.ak
        
        let grainGeneratorLeftChannel = AKGranularSynthesisTexture(
            grainFunctionTable: soundFileLeftChannel,
            windowFunctionTable: window,
            maximumGrainDuration: dur,
            averageGrainDuration: avgDur,
            maximumFrequencyDeviation: freqVar,
            grainFrequency: freq,
            maximumAmplitudeDeviation: ampMod,
            grainAmplitude: 0.ak,
            grainDensity: density,
            useRandomGrainOffset: true)
        
        let grainGeneratorRightChannel = AKGranularSynthesisTexture(
            grainFunctionTable: soundFileRightChannel,
            windowFunctionTable: window,
            maximumGrainDuration: dur,
            averageGrainDuration: avgDur,
            maximumFrequencyDeviation: freqVar,
            grainFrequency: freq,
            maximumAmplitudeDeviation: ampMod,
            grainAmplitude: 0.ak,
            grainDensity: density,
            useRandomGrainOffset: true)
        
        grainGeneratorLeftChannel.grainAmplitude = amplitude
        grainGeneratorRightChannel.grainAmplitude = amplitude
        
        grainGeneratorLeftChannel.grainFrequency = transpose * freq
        grainGeneratorRightChannel.grainFrequency = transpose * freq
        
        connect(grainGeneratorLeftChannel)
        connect(grainGeneratorRightChannel)
        
        connect(AKAudioOutput(leftAudio: grainGeneratorLeftChannel, rightAudio: grainGeneratorRightChannel))
    }
    
}
