//
//  ViewController.swift
//  Promo Player
//
//  Created by Srdjan Markovic on 28/10/2019.
//  Copyright © 2019 Red Black Tree d.o.o. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var promoPlayerView: PromoPlayerView!

    @IBOutlet weak var placeholderLabel: NSTextField!
        
    private lazy var workQueue: OperationQueue = {
        let providerQueue = OperationQueue()
        providerQueue.qualityOfService = .userInitiated
        return providerQueue
    }()

    private lazy var destinationURL: URL = {
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Drops")
        try? FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        return destinationURL
    }()
    
    private func handleFile(at url: URL) {
        OperationQueue.main.addOperation {
            self.placeholderLabel.isHidden = true
            self.promoPlayerView.add(url: url)
            self.promoPlayerView.play()
        }
    }

    private func handleError(_ error: Error) {
        OperationQueue.main.addOperation {
            if let window = self.view.window {
                self.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
            } else {
                self.presentError(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: PromoPlayerViewDelegate {
    func draggingEntered(forView view: PromoPlayerView, sender: NSDraggingInfo) -> NSDragOperation {
        return sender.draggingSourceOperationMask.intersection([.copy])
    }
    
    func performDragOperation(forView view: PromoPlayerView, sender: NSDraggingInfo) -> Bool {
        let supportedClasses = [
            NSFilePromiseReceiver.self,
            NSURL.self
        ]

        let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true,
            .urlReadingContentsConformToTypes: [ kUTTypeMovie ]
        ]

        sender.enumerateDraggingItems(options: [], for: nil, classes: supportedClasses, searchOptions: searchOptions) { (draggingItem, _, _) in
            switch draggingItem.item {
            case let filePromiseReceiver as NSFilePromiseReceiver:
                filePromiseReceiver.receivePromisedFiles(atDestination: self.destinationURL, options: [:], operationQueue: self.workQueue) { (fileURL, error) in
                    if let error = error {
                        self.handleError(error)
                    } else {
                        self.handleFile(at: fileURL)
                    }
                }
            case let fileURL as URL:
                self.handleFile(at: fileURL)
            default:
                break
            }
        }
        
        return true
    }
}
