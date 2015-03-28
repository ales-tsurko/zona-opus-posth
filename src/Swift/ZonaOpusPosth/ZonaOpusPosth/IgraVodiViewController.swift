//
//  IgraVodiViewController.swift
//  ZonaOpusPosth
//
//  Created by Ales Tsurko on 14.03.15.
//  Copyright (c) 2015 Ales Tsurko. All rights reserved.
//

import Cocoa

class IgraVodiViewController: NSViewController {
    
    @IBOutlet weak var loSlider: NSSlider!
    @IBOutlet weak var hiSlider: NSSlider!
    @IBOutlet weak var linkChannelsToggle: NSButton!
    private var channelsDifference: Double!
    let igraSynthLo = IgraVodiSynth(rate: 0.5)
    let igraSynthHi = IgraVodiSynth(rate: 2)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKOrchestra.addInstrument(igraSynthLo)
        AKOrchestra.addInstrument(igraSynthHi)
        
        updateSliders()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        igraSynthLo.play()
        igraSynthHi.play()
    }
    
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        loSlider.floatValue = 0
        hiSlider.floatValue = 0
        loSliderAction(loSlider)
        hiSliderAction(hiSlider)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        igraSynthLo.stop()
        igraSynthHi.stop()
    }
    
    func updateSliders() {
        AKTools.setSlider(loSlider, withProperty: igraSynthLo.amplitude)
        AKTools.setSlider(hiSlider, withProperty: igraSynthHi.amplitude)
    }
   
    @IBAction func linkChannelsAction(sender: NSButton) {
        channelsDifference = loSlider.doubleValue - hiSlider.doubleValue
    }
    
    @IBAction func loSliderAction(sender: NSSlider) {
        AKTools.setProperty(igraSynthLo.amplitude, withSlider: sender)
        
        if(linkChannelsToggle.state == 1) {
            hiSlider.doubleValue = sender.doubleValue - channelsDifference
            AKTools.setProperty(igraSynthHi.amplitude, withSlider: hiSlider)
        }
    }
    
    @IBAction func hiSliderAction(sender: NSSlider) {
        AKTools.setProperty(igraSynthHi.amplitude, withSlider: sender)
        
        if(linkChannelsToggle.state == 1) {
            loSlider.doubleValue = sender.doubleValue + channelsDifference
            AKTools.setProperty(igraSynthLo.amplitude, withSlider: loSlider)
        }
    }
    
    @IBAction func transposeAction(sender: NSPopUpButton) {
        var index: Float
        index = Float(sender.indexOfSelectedItem)
        igraSynthLo.transpose.setValue(index.midiratio)
        igraSynthHi.transpose.setValue(index.midiratio)
    }
}
