//
//  CommentViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/09/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController, UITextViewDelegate {
    
    //properties
    var selectedId = 0
    var messageSent = false
    var isNavBar = false

    //@IBOutlets
    @IBOutlet weak var designButton: UIButton!
    @IBOutlet weak var comment: UITextView!
    
    //@IBAction
    @IBAction func send(sender: AnyObject) {
        if !self.messageSent {
            SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
            SwiftSpinner.show("Envoi en cours...")
            if self.comment.text == "Taper votre commentaire ici :" || self.comment.text == "" {
                SwiftSpinner.hide()
                // create alert controller
                let myAlert = UIAlertController(title: "Erreur", message: "Votre message est vide !", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                // add "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                if !self.isNavBar {
                    //we're in a modal view, we need an option to cancel (in navMode, we use the back button)
                    myAlert.addAction(UIAlertAction(title: "Quitter", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                }
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
                self.designButton.setTitle("Réessayer", forState: UIControlState.Normal)
            } else {
                User.currentUser!.sendComment(self.selectedId, comment: self.comment.text, callback: { (title, message, result) -> Void in
                    SwiftSpinner.hide()
                    // create alert controller
                    let myAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    myAlert.view.tintColor = Colors.green
                    // add "OK" button
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    self.presentViewController(myAlert, animated: true, completion: nil)
                    if result { //message sent
                        self.messageSent = true
                        if self.isNavBar {
                            //we are in a navigation controller, we use back button to leave so we disable the button
                            self.designButton.enabled = false
                            self.designButton.backgroundColor = Colors.darkGrey
                        } else {
                            //we're in a modal view, we use this button to dismiss
                            self.designButton.setTitle("OK", forState: UIControlState.Normal)
                        }
                    } else { //error
                        self.messageSent = false
                        self.designButton.setTitle("Réessayer", forState: UIControlState.Normal)
                        if !self.isNavBar {
                            //we're in a modal view, we need an option to cancel (in navMode, we use the back button)
                            myAlert.addAction(UIAlertAction(title: "Quitter", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }))
                        }
                    }
                })
            }
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageSent = false
        if let _ = self.navigationController {
            self.isNavBar = true
        }
        //sync
        FactoryHistory.getHistory().sync()
        self.designButton.setTitle("Envoyé", forState: UIControlState.Disabled)
        self.view!.backgroundColor = Colors.greyBackground
        self.title = "Envoyer un commentaire"
        self.comment.text = "Taper votre commentaire ici :"
        self.comment.textColor = UIColor.lightGrayColor()
        self.designButton.layer.cornerRadius = 6
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
    }
    
    func logout() {
        print("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = Colors.green
        // add "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Destructive, handler: nil))
        // add "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //UITextViewDelegate Methods
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = Colors.green
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Taper votre commentaire ici :"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }


}
