//
//  ScreenSleep.swift
//  Promo Player
//
//  Created by Srdjan Markovic on 02/11/2019.
//  Copyright © 2019 Red Black Tree d.o.o. All rights reserved.
//

import Foundation
import IOKit
import IOKit.pwr_mgt

struct ScreenSleep {
    static var noSleepAssertionID: IOPMAssertionID = 0
    static var noSleepReturn: IOReturn? // Could probably be replaced by a boolean value, for example 'isBlockingSleep', just make sure 'IOPMAssertionRelease' doesn't get called, if 'IOPMAssertionCreateWithName' failed.
    
    static func disable(reason: String = "Unknown reason") -> Bool? {
        guard noSleepReturn == nil else { return nil }
        noSleepReturn = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                    IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                    reason as CFString,
                                                    &noSleepAssertionID)
        return noSleepReturn == kIOReturnSuccess
    }
    
    static func enable() -> Bool {
        if noSleepReturn == kIOReturnSuccess {
            _ = IOPMAssertionRelease(noSleepAssertionID) == kIOReturnSuccess
            noSleepReturn = nil
            return true
        }
        return false
    }
    
    static func toggle() -> Bool {
        if noSleepReturn == kIOReturnSuccess {
            return enable()
        }
        else {
            return disable() ?? false
        }
    }
}

