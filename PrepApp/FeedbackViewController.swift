//
//  FeedbackViewController.swift
//  PrepApp
//
//  Created by Mikael Vandeginste on 15/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    
    var topics = ["Une suggestion/idée", "Un bug/remarque", "Une nouvelle fonctionnalité", "Un autre commentaire"]
    var selectedTopic = 0
    
    
    @IBOutlet weak var topicsPicker: UIPickerView!
    @IBOutlet weak var designButton: UIButton!
    @IBOutlet weak var feedback: UITextView!

    @IBAction func send(sender: AnyObject) {
        self.sendFeedback()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Envoyer un feedback"
        self.feedback.text = "Taper votre commentaire ici :"
        self.feedback.textColor = UIColor.lightGrayColor()
        self.designButton.layer.cornerRadius = 6
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
    }
    
    func logout() {
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreenAppButtons
        // add an "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Default, handler: nil))
        // add an "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    func sendFeedback() {
        if self.feedback.text == "Taper votre feedback ici :" || self.feedback.text == "" {
            // create alert controller
            let myAlert = UIAlertController(title: "Erreur", message: "Votre message est vide !", preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = colorGreenAppButtons
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
        } else {
            User.currentUser!.sendFeedback(self.topics[self.selectedTopic], feedback: self.feedback.text) { (title, message, result) -> Void in
                // create alert controller
                let myAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreenAppButtons
                // add an "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                    if result {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        }
    }
    
    //UIPickerViewDataSource/Delegate Methods
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.topics.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.topics[row]
    }
    
    //UITextViewDelegate Methods
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = colorGreenAppButtons
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Taper votre feedback ici :"
            textView.textColor = UIColor.lightGrayColor()
        }
    }

}
