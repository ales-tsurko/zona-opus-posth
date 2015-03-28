//
//  AppDelegate.swift
//  ZonaOpusPosth
//
//  Created by Ales Tsurko on 05.03.15.
//  Copyright (c) 2015 Ales Tsurko. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        AKOrchestra.start()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

