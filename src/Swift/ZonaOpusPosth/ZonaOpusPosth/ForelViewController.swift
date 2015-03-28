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
    
    override func awakeFromNib() {
        waveformView1.drawWaveform("forel", fileType: "wav", gain: 6)
        waveformView2.drawWaveform("forel", fileType: "wav", gain: 6)
        waveformView3.drawWaveform("forel", fileType: "wav", gain: 6)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKOrchestra.addInstrument(track1)
        
//        track1.volume = volumeSlider.floatValue
//        track2.volume = volumeSlider.floatValue
//        track3.volume = volumeSlider.floatValue
//        
        firstTrackNumberBoxOct.floatValue = -1
        secondTrackNumberBoxOct.floatValue = -2
        thirdTrackNumberBoxOct.floatValue = -3
        
        track1.rate.setValue(pow(2, firstTrackNumberBoxOct.floatValue))
//        track2.setRate = pow(2, secondTrackNumberBoxOct.floatValue)
//        track3.setRate = pow(2, thirdTrackNumberBoxOct.floatValue)
//        
//        // Update cursor position
        NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("updateCursorPosition"), userInfo: nil, repeats: true)
        
    }
    
    func updateCursorPosition() {
        waveformView1.cursor.position = CGFloat(track1.playingPosition.value())
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        
//        track1.pause()
//        track2.pause()
//        track3.pause()
        pauseButton.state = 0
        track1.stop()
    }
    
    @IBAction func resetButonAction(sender: NSButton) {
        // назначение индекса фейзера на 0
//        track2.resetToZeroPosition()
//        track3.resetToZeroPosition()
    }
    
    @IBAction func pauseButtonAction(sender: NSButton) {
        if(pauseButton.state == 0) {
            track1.rate.setValue(0)
//            track2.pause()
//            track3.pause()
        } else {
            track1.rate.setValue(pow(2, firstTrackNumberBoxOct.floatValue))
            // здесь, все-таки, придется делать иначе, видимо. Нужно запоминать позицию, на
            // которой остановился запускать метод stop(), а потом снова продолжать с нее.
            // Или просто сюда пустить позиции, на которой остановился то есть вовне if 
            // находится переменная, хранящая позицию. Когда останавливается, записывается позиция
            // в эту переменную и используется уже в else.
            track1.play()
        }
    }
   
    @IBAction func volumeSliderAction(sender: NSSlider) {
//        track1.volume = sender.floatValue
//        track2.volume = sender.floatValue
//        track3.volume = sender.floatValue
    }
    
    @IBAction func firstTrackNumberBoxAction(sender: NSTextField) {
        track1.rate.setValue(pow(2, sender.floatValue))
        firstTrackStepperOct.floatValue = sender.floatValue
        
    }
    
    @IBAction func secondTrackNumberBoxAction(sender: NSTextField) {
        secondTrackStepperOct.floatValue = sender.floatValue
    }
    
    @IBAction func thirdTrackNumberBoxAction(sender: NSTextField) {
        thirdTrackStepperOct.floatValue = sender.floatValue
    }
    

    @IBAction func firstOctChangeAction(sender: NSStepper) {
        track1.rate.setValue(pow(2, sender.floatValue))
        firstTrackNumberBoxOct.floatValue = sender.floatValue
    }
    
    @IBAction func secondOctChangeAction(sender: NSStepper) {
        secondTrackNumberBoxOct.floatValue = sender.floatValue
    }
    
    @IBAction func thirdOctChangeAction(sender: NSStepper) {
        thirdTrackNumberBoxOct.floatValue = sender.floatValue
    }
}