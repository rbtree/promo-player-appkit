//
//  OverlayView.swift
//  Promo Player
//
//  Created by Srdjan Markovic on 02/11/2019.
//  Copyright © 2019 Red Black Tree d.o.o. All rights reserved.
//

import Foundation
import AppKit

class OverlayView: NSView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.wantsLayer = true
            self.layer!.cornerRadius = cornerRadius
            self.layer!.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var backgroundColor: NSColor = .clear {
        didSet {
            self.wantsLayer = true
            self.layer!.backgroundColor = backgroundColor.cgColor
        }
    }
}
