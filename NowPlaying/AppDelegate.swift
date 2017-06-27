//
//  AppDelegate.swift
//  NowPlaying
//
//  Created by zvorak on 2017/06/27.
//  Copyright © 2017年 oweleo. All rights reserved.
//

import Cocoa

import ScriptingBridge

@objc protocol iTunesTrack {
    @objc optional var name: String { get }
    @objc optional var album: String { get }
    @objc optional var artworks: Array<iTunesArtwork> { get }
}

@objc protocol iTunesArtwork {
    
}

@objc protocol iTunesApplication {
    @objc optional var currentTrack: iTunesTrack? { get }
}
extension SBApplication : iTunesApplication {}



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let mainBundle: Bundle = Bundle.main
        let pathToUserDefaultsValues: String? = mainBundle.path(forResource: "UserDefaults", ofType: "plist")
        
        let initialUserDefaultsValues: NSDictionary? = NSDictionary(contentsOfFile: pathToUserDefaultsValues!)
        UserDefaults.standard.register(defaults: initialUserDefaultsValues as! [String : AnyObject])
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(AppDelegate.onChangeTrack(_:)), name: NSNotification.Name(rawValue: "com.apple.iTunes.playerInfo"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(AppDelegate.allNotificationReceived(_:)), name: nil, object: nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    let session: URLSession = URLSession.shared
    
    func onChangeTrack(_ notification: Notification?) {
        let userInfo = (notification as NSNotification?)?.userInfo
        print(userInfo ?? "")
        
        if (userInfo!["Player State"] as! String) == "Playing" {
            guard let
                displayLine0: String = userInfo!["Display Line 0"] as? String,
                let displayLine1: String = userInfo!["Display Line 1"] as? String,
                let storeURL: String = userInfo!["Store URL"] as? String else {
                    return
            }
            
            let httpStoreURL = storeURL.replacingOccurrences(of: "itms://", with: "http://")
            
            let formatter: DateFormatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.none
            formatter.timeStyle = DateFormatter.Style.short
            
            let hookURL = UserDefaults.standard.string(forKey: "hookURL")!
            let params: [String: Any] = [
                "channel": UserDefaults.standard.string(forKey: "channel")! as AnyObject,
                "username": "nowplayingbot" as AnyObject,
                "text": String(format: "%@ %@", arguments: [formatter.string(from: Date()), displayLine0]) as AnyObject,
                "attachments": [[
                    "title": displayLine1,
                    "title_link": httpStoreURL
                    ]]
            ]
            let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: hookURL)!)
            
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.init(rawValue: 2))
            } catch {
                // Error Handling
                print("NSJSONSerialization Error")
                return
            }
            session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                // code
            }).resume()
        }
    }
    
    func allNotificationReceived(_ notification: Notification?) {
        NSLog("name = \(notification?.name) object = \(notification?.object) userInfo = \((notification as NSNotification?)?.userInfo)")
    }
}

