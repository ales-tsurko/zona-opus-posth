//
//  ForelViewController.swift
//  ZonaOpusPosth
//
//  Created by Ales Tsurko on 20.03.15.
//  Copyright (c) 2015 Ales Tsurko. All rights reserved.

class ForelViewController: NSViewController {
    
    @IBOutlet weak var waveformView1: ZOWaveformView!
    @IBOutlet weak var waveformView2: ZOWaveformView!
    @IBOutlet weak var waveformView3: ZOWaveformView!
    
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBOutlet weak var firstTrackNumberBoxOct: NSTextField!
    @IBOutlet weak var secondTrackNumberBoxOct: NSTextField!
    @IBOutlet weak var thirdTrackNumberBoxOct: NSTextField!
    @IBOutlet weak var firstTrackStepperOct: NSStepper!
    @IBOutlet weak var secondTrackStepperOct: NSStepper!
    @IBOutlet weak var thirdTrackStepperOct: NSStepper!
    
    let track1 = AudioTrack(fileName: "forel", fileType: "wav")
    let track2 = AudioTrack(fileName: "forel", fileType: "wav")
    let track3 = AudioTrack(fileName: "forel", fileType: "wav")
    
    var playingPositionTrack1: Float!
    var playingPositionTrack2: Float!
    var playingPositionTrack3: Float!
    
    var isPlaying: Bool!
    
    override func awakeFromNib() {
        waveformView1.drawWaveform("forel", fileType: "wav", gain: 6)
        waveformView2.drawWaveform("forel", fileType: "wav", gain: 6)
        waveformView3.drawWaveform("forel", fileType: "wav", gain: 6)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playingPositionTrack1 = 0
        playingPositionTrack2 = 0
        playingPositionTrack3 = 0
        
        isPlaying = false
        
        AKOrchestra.addInstrument(track1)
        AKOrchestra.addInstrument(track2)
        AKOrchestra.addInstrument(track3)
        
        firstTrackNumberBoxOct.floatValue = -1
        secondTrackNumberBoxOct.floatValue = -2
        thirdTrackNumberBoxOct.floatValue = -3
        
        track1.rate.setValue(pow(2, firstTrackNumberBoxOct.floatValue))
        track2.rate.setValue(pow(2, secondTrackNumberBoxOct.floatValue))
        track3.rate.setValue(pow(2, thirdTrackNumberBoxOct.floatValue))
        
        // Update cursor position
        NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("updateCursorPosition"), userInfo: nil, repeats: true)
        
        updateSliders()
    }
    
    func updateSliders() {
        AKTools.setSlider(volumeSlider, withProperty: track1.amplitude)
        AKTools.setSlider(volumeSlider, withProperty: track2.amplitude)
        AKTools.setSlider(volumeSlider, withProperty: track3.amplitude)
    }
    
    func updateCursorPosition() {
        waveformView1.cursor.position = CGFloat(track1.playingPosition.value()%1.0)
        waveformView2.cursor.position = CGFloat(track2.playingPosition.value()%1.0)
        waveformView3.cursor.position = CGFloat(track3.playingPosition.value()%1.0)
    }
    
    func play() {
        isPlaying = true
        
        let playback1 = Playback(startTime: playingPositionTrack1)
        let playback2 = Playback(startTime: playingPositionTrack2)
        let playback3 = Playback(startTime: playingPositionTrack3)
        
        track1.playNote(playback1)
        track2.playNote(playback2)
        track3.playNote(playback3)
    }
    
    func stop() {
        isPlaying = false
        
        playingPositionTrack1 = track1.playingPosition.value()
        track1.stop()
        playingPositionTrack2 = track2.playingPosition.value()
        track2.stop()
        playingPositionTrack3 = track3.playingPosition.value()
        track3.stop()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        volumeSlider.floatValue = 0
        volumeSliderAction(volumeSlider)
        pauseButton.state = 0
        pauseButtonAction(pauseButton)
        
        track1.playingPosition.setValue(0)
        track2.playingPosition.setValue(0)
        track3.playingPosition.setValue(0)
    }
    
    @IBAction func resetButonAction(sender: NSButton) {
        playingPositionTrack1 = 0
        track1.stop()
        playingPositionTrack2 = 0
        track2.stop()
        playingPositionTrack3 = 0
        track3.stop()
        
        track1.playingPosition.setValue(playingPositionTrack1)
        track2.playingPosition.setValue(playingPositionTrack2)
        track3.playingPosition.setValue(playingPositionTrack3)
        if(pauseButton.state == 1) {
            pauseButton.state = 0
        }
    }
    
    @IBAction func pauseButtonAction(sender: NSButton) {
        if(pauseButton.state == 0) {
            stop()
        } else {
            play()
        }
    }
    
    @IBAction func volumeSliderAction(sender: NSSlider) {
        AKTools.setProperty(track1.amplitude, withSlider: sender)
        AKTools.setProperty(track2.amplitude, withSlider: sender)
        AKTools.setProperty(track3.amplitude, withSlider: sender)
    }
    
    @IBAction func firstTrackNumberBoxAction(sender: NSTextField) {
        track1.rate.setValue(pow(2, sender.floatValue))
        firstTrackStepperOct.floatValue = sender.floatValue
    }
    
    @IBAction func secondTrackNumberBoxAction(sender: NSTextField) {
        track2.rate.setValue(pow(2, sender.floatValue))
        secondTrackStepperOct.floatValue = sender.floatValue
    }
    
    @IBAction func thirdTrackNumberBoxAction(sender: NSTextField) {
        track3.rate.setValue(pow(2, sender.floatValue))
        thirdTrackStepperOct.floatValue = sender.floatValue
    }
    
    
    @IBAction func firstOctChangeAction(sender: NSStepper) {
        track1.rate.setValue(pow(2, sender.floatValue))
        firstTrackNumberBoxOct.floatValue = sender.floatValue
    }
    
    @IBAction func secondOctChangeAction(sender: NSStepper) {
        track2.rate.setValue(pow(2, sender.floatValue))
        secondTrackNumberBoxOct.floatValue = sender.floatValue
    }
    
    @IBAction func thirdOctChangeAction(sender: NSStepper) {
        track3.rate.setValue(pow(2, sender.floatValue))
        thirdTrackNumberBoxOct.floatValue = sender.floatValue
    }
    
    @IBAction func transposeAction(sender: NSPopUpButton) {
        var index: Float
        index = Float(sender.indexOfSelectedItem)
        track1.transpose.setValue(index.midiratio)
        track2.transpose.setValue(index.midiratio)
        track3.transpose.setValue(index.midiratio)
    }
}