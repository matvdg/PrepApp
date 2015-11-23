//
//  SyncViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 02/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class SyncViewController: UIViewController {
	
    static var widthImage: CGFloat = 300

	var timer = NSTimer()
    var nbrFrame: Int = 0
    var percentage: Int = 0
	let frames = 350
    var version: Int = 0
    
    @IBOutlet weak var progression: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    @IBAction func tryAgain(sender: AnyObject) {
        self.progression.hidden = false
        self.tryAgainButton.hidden = true
        self.logo.image = UIImage(named: "l0")
        self.percentage = 0
        self.nbrFrame = 0
        FactorySync.errorNetwork = false
        self.sync()
    }

	override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue(), {
            SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
            SwiftSpinner.show("Veuillez patienter...")
        })
        self.view!.backgroundColor = Colors.greyBackground
        SyncViewController.widthImage = self.view.frame.width - 20
		
        self.tryAgainButton.layer.cornerRadius = 6
        self.tryAgainButton.hidden = true
        self.logo.image = UIImage(named: "l350")
        self.progression.text = ""
	}
    
    override func viewDidAppear(animated: Bool) {
        FactorySync.getImageManager().hasFinishedSync = false
        FactorySync.getQuestionManager().hasFinishedSync = false
        if User.authenticated == false {
            self.progression.text = "Déconnexion..."
            NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.logo.image = UIImage(named: "l350")
            self.progression.text = ""
            self.sync()
        }
        
    }
    
    func sync(){
        if FactorySync.production {
            FactorySync.offlineMode = false
            FactorySync.getConfigManager().getLastVersion { (version) -> Void in
                if let versionDB: Int = version { //online mode
                    FactorySync.getConfigManager().saveConfig({ (result) -> Void in
                        if result {
                            FactoryHistory.getHistory().sync()
                            print("localVersion = \(FactorySync.getConfigManager().loadVersion()) dbVersion = \(versionDB)")
                            if FactorySync.getConfigManager().loadVersion() != versionDB { //syncing...
                                SwiftSpinner.hide()
                                FactorySync.sync()
                                self.timer = NSTimer.scheduledTimerWithTimeInterval(0.030, target: self, selector: Selector("result"), userInfo: nil, repeats: true)
                                self.version = versionDB
                            } else { //no sync needed
                                print("no need to sync")
                                SwiftSpinner.hide()
                                self.performSegueWithIdentifier("syncDidFinish", sender: self)
                            }
                        } else {
                            SwiftSpinner.hide()
                            Sound.playTrack("error")
                            // create alert controller
                            let myAlert = UIAlertController(title: "Erreur de téléchargement", message: "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
                            myAlert.view.tintColor = Colors.green
                            // add "OK" button
                            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                self.progression.hidden = true
                                self.tryAgainButton.hidden = false
                                self.logo.image = UIImage(named: "l350")
                                
                            }))
                            // show the alert
                            self.presentViewController(myAlert, animated: true, completion: nil)
                        }
                    })
                    
                } else { //offline mode
                    if FactorySync.getConfigManager().loadVersion() == 0 { //if the app has never synced, can't run the app
                        SwiftSpinner.hide()
                        Sound.playTrack("error")
                        // create alert controller
                        let myAlert = UIAlertController(title: "Erreur de téléchargement", message: "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
                        myAlert.view.tintColor = Colors.green
                        // add "OK" button
                        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            self.progression.hidden = true
                            self.tryAgainButton.hidden = false
                            self.logo.image = UIImage(named: "l350")
                            
                        }))
                        // show the alert
                        self.presentViewController(myAlert, animated: true, completion: nil)

                        
                    } else { //run the app in offline mode
                        SwiftSpinner.hide()
                        FactorySync.offlineMode = true
                        print("offline mode")
                        self.performSegueWithIdentifier("syncDidFinish", sender: self)
                    }
                }
            }
        } else {
            self.performSegueWithIdentifier("syncDidFinish", sender: self)
        }
    }
    
	func result(){
      
        if FactorySync.errorNetwork { //handling network errors or bad network
            timer.invalidate()
            Sound.playTrack("error")
            self.logo.image = UIImage(named: "l350")
            self.progression.text = ""
            // create alert controller
            let myAlert = UIAlertController(title: "Erreur de téléchargement", message: "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = Colors.green
            // add "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.progression.hidden = true
                self.tryAgainButton.hidden = false
                self.logo.image = UIImage(named: "l350")
                
            }))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
            
            
        } else { //progression of sync
            
            var name = ""
            //computing percentage progression for Questions DB & Images (We neglect to take into account the chapters or materials, as they're very light.)
            
            if !FactorySync.getQuestionManager().hasFinishedSync { //downloading questions
                
                if FactorySync.getQuestionManager().questionsToSave != 0 {
                    self.percentage = (FactorySync.getQuestionManager().questionsSaved * 100) / (FactorySync.getQuestionManager().questionsToSave)
                    self.nbrFrame = (self.percentage * self.frames) / 100
                    name = "l\(self.nbrFrame)"
                    self.logo.image = UIImage(named: name)
                    self.progression.text = "Téléchargement de la question \(FactorySync.getQuestionManager().questionsSaved) sur \(FactorySync.getQuestionManager().questionsToSave)\n \(self.percentage)%"
                    
                } else {
                    self.progression.text = "Connexion au serveur Prep'App..."
                }
                
            } else { //downloading images
                if FactorySync.getImageManager().numberOfImagesToDownload != 0 {
                    self.percentage = (FactorySync.getImageManager().numberOfImagesDownloaded * 100) / (FactorySync.getImageManager().numberOfImagesToDownload)
                    self.nbrFrame = (self.percentage * self.frames) / 100
                    name = "l\(self.nbrFrame)"
                    self.logo.image = UIImage(named: name)
                    self.progression.text = "Téléchargement du visuel \(FactorySync.getImageManager().numberOfImagesDownloaded) sur \(FactorySync.getImageManager().numberOfImagesToDownload)\n \(self.percentage)%"
                    
                } else {
                    self.progression.text = "Questions téléchargées !"
                }
                
                //the end...
                if  (FactorySync.getImageManager().hasFinishedSync == true && FactorySync.getQuestionManager().hasFinishedSync == true) {
                    //go to main menu
                    self.logo.image = UIImage(named: "l350")
                    self.progression.text = ""
                    timer.invalidate()
                    FactorySync.getConfigManager().saveVersion(self.version)
                    self.performSegueWithIdentifier("syncDidFinish", sender: self)
                }

            }
        }
	}
	
}

