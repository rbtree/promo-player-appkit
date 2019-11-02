//
//  AppDelegate.swift
//  Promo Player
//
//  Created by Srdjan Markovic on 28/10/2019.
//  Copyright © 2019 Red Black Tree d.o.o. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSApplication.shared.mainWindow?.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        NSCursor.setHiddenUntilMouseMoves(true)
        _ = ScreenSleep.disable(reason: "Promo Player in Full Screen")
    }
    
    func windowDidExitFullScreen(_ notification: Notification) {
        NSCursor.setHiddenUntilMouseMoves(false)
        _ = ScreenSleep.enable()
    }
}
