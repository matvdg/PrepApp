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
    private static var volume: Float = 0.5
    
    class func playTrack(sound: String) {
        
        if UserPreferences.sounds {
            var mediapath = "sounds/\(sound)"
            
            if let path = NSBundle.mainBundle().pathForResource(mediapath, ofType: "caf") {
                player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path), fileTypeHint: "caf", error: nil)
                player!.volume = self.volume
                player!.numberOfLoops = 0
                player!.prepareToPlay()
                player?.play()
            }
        }
    }
    
    class func playPage() {
        
        if UserPreferences.sounds {
            
            let random = Int(arc4random() % 9)
            var mediapath = "sounds/page\(random)"
            
            if let path = NSBundle.mainBundle().pathForResource(mediapath, ofType: "caf") {
                player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path), fileTypeHint: "caf", error: nil)
                player!.volume = self.volume
                player!.numberOfLoops = 0
                player!.prepareToPlay()
                player?.play()
            }
            
        }
        
    }
    
}
