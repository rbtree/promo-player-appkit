//
//  DragDestinationView.swift
//  Promo Player
//
//  Created by Srdjan Markovic on 28/10/2019.
//  Copyright © 2019 Red Black Tree d.o.o. All rights reserved.
//

import Foundation
import AppKit
import AVKit

@objc protocol PromoPlayerViewDelegate: AnyObject {
    func draggingEntered(forDragDestinationView dragDestinationView: PromoPlayerView, sender: NSDraggingInfo) -> NSDragOperation
    func performDragOperation(forDragDestinationView dragDestinationView: PromoPlayerView, sender: NSDraggingInfo) -> Bool
}

class PromoPlayerView: NSView {

    // MARK: Private outlet variables
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var playerView: AVPlayerView!

    @IBOutlet weak var delegate: PromoPlayerViewDelegate?

    // MARK: Public properties
    
    var isHighlighted: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    var player: AVQueuePlayer?
    var playerLayer: AVPlayerLayer?

    // MARK: Public functions
    
    public func clear() {
        self.player?.removeAllItems()
    }
    
    public func add(urls: [URL]) {
        urls.forEach { (url) in
            self.add(url: url)
        }
    }
    
    public func add(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.player?.insert(playerItem, after: self.player?.items().last)
        
        self.play()
    }
        
    public func play() {
        // TODO: better init
        if self.playerLayer == nil {
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.playerView!.bounds
            playerLayer.videoGravity = .resizeAspect

            self.playerView!.layer!.addSublayer(playerLayer)
            self.playerLayer = playerLayer
        }

        self.player?.play()
    }
    
    // MARK: Initializers
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }

    private func setup() {
        registerForDraggedTypes([.fileURL])
                
        let player = AVQueuePlayer(items: [AVPlayerItem]())
        // Prevent advancing to the next player item automatically
        player.actionAtItemEnd = .none
        self.player = player
        
        //self.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
    }
    
    deinit {
        //self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: NSKeyPath observers
    //override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    //    if keyPath == "timeControlStatus",
    //        let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int,
    //        let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
    //        let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
    //        let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
    //        if newStatus != oldStatus {
    //            DispatchQueue.main.async { [weak self] in
    //                if let progressIndicator = self?.progressIndicator {
    //                    if newStatus == .playing || newStatus == .paused {
    //                        progressIndicator.isHidden = true
    //                        progressIndicator.stopAnimation(self)
    //                    } else {
    //                        progressIndicator.isHidden = false
    //                        progressIndicator.startAnimation(self)
    //                    }
    //                }
    //            }
    //        }
    //    }
    //}
    
    // MARK: - NotificationCenter observers
    
    @objc func playerEndedPlaying(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            // The finished player item
            if let item = notification.object as? AVPlayerItem {
                // Advance to the next item (removes finished player item from the play queue)
                self?.player?.advanceToNextItem()
                // Rewind the finished player item to beginning
                item.seek(to: .zero) { _ in
                    // Re-insert the finished player item at the end of the play queue
                    self?.player?.insert(item, after: self?.player?.items().last)
                }
            }
        }
    }
    
    // MARK: - NSView overrides

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        self.playerLayer?.frame = self.playerView.bounds
    }
 
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if isHighlighted {
            NSGraphicsContext.saveGraphicsState()
            NSFocusRingPlacement.only.set()
            bounds.insetBy(dx: 2, dy: 2).fill()
            NSGraphicsContext.restoreGraphicsState()
        }
    }
    
    // MARK: - NSResponder overrides
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    override func keyDown(with event: NSEvent) {
        var handled = false
        
        let characters = event.charactersIgnoringModifiers?.lowercased()
        switch characters {
        case "q":
            handled = true
            NSApp.terminate(self)
        case "f":
            handled = true
            window?.toggleFullScreen(self)
        default:
            break
        }
        
        if handled {
            super.keyDown(with: event)
        }
    }

    // MARK: - NSDraggingDestination overrides

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        var result: NSDragOperation = []
        if let delegate = delegate {
            result = delegate.draggingEntered(forDragDestinationView: self, sender: sender)
            isHighlighted = (result != [])
        }
        return result
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return delegate?.performDragOperation(forDragDestinationView: self, sender: sender) ?? true
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isHighlighted = false
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        isHighlighted = false
    }
}
