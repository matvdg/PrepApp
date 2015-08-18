//
//  SoundSystem.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 09/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import AVFoundation

class Sound {
    private static var player: AVAudioPlayer?
    
    class func playTrack(sound: String) {
        
        if User.currentUser!.sounds {
            var mediapath = "sounds/\(sound)"
            
            if let path = NSBundle.mainBundle().pathForResource(mediapath, ofType: "caf") {
                player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path), fileTypeHint: "caf", error: nil)
                player!.volume = 1
                player!.numberOfLoops = 0
                player!.prepareToPlay()
                player?.play()
            }
 
        }
        
    }
    
    class func playPage() {
        
        if User.currentUser!.sounds {
            
            let random = (Int(arc4random())%9)
            var mediapath = "sounds/page\(random)"
            
            if let path = NSBundle.mainBundle().pathForResource(mediapath, ofType: "caf") {
                player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path), fileTypeHint: "caf", error: nil)
                player!.volume = 1
                player!.numberOfLoops = 0
                player!.prepareToPlay()
                player?.play()
            }
            
        }
        
    }
    
}
