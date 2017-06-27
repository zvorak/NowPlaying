//
//  ViewController.swift
//  NowPlaying
//
//  Created by zvorak on 2017/06/27.
//  Copyright © 2017年 oweleo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        DistributedNotificationCenter.default().addObserver(self,
                                                            selector: #selector(onChangeTrack(_:)),
                                                            name: NSNotification.Name(rawValue: "com.apple.iTunes.playerInfo"),
                                                            object: nil)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBOutlet var trackArtist: NSTextField!
    @IBOutlet var trackTitle: NSTextField!
    
    let session: URLSession = URLSession.shared
    
    func onChangeTrack(_ notification: Notification?) {
        let userInfo: NSDictionary! = (notification as NSNotification?)?.userInfo as NSDictionary!
        print(userInfo)
        
        if let val = userInfo["Artist"] {
            self.trackArtist.stringValue = val as! String;
        }
        if let val = userInfo["Name"] {
            self.trackTitle.stringValue = val as! String;
        }
    }
}

