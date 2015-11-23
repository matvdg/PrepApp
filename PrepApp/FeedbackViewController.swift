//
//  FeedbackViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 15/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    
    var topics = ["Suggestion/idée", "Bug/remarque", "Autre"]
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var topicsPicker: UIPickerView!
    @IBOutlet weak var designButton: UIButton!
    @IBOutlet weak var feedback: UITextView!

    @IBAction func send(sender: AnyObject) {
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        SwiftSpinner.show("Envoi en cours...")
        if self.feedback.text == "Taper votre feedback ici :" || self.feedback.text == "" {
            SwiftSpinner.hide()
            // create alert controller
            let myAlert = UIAlertController(title: "Erreur", message: "Votre message est vide !", preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = Colors.green
            // add "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
            self.designButton.setTitle("Réessayer", forState: UIControlState.Normal)
        } else {
            User.currentUser!.sendFeedback(self.topics[self.topicsPicker.selectedRowInComponent(0)], feedback: self.feedback.text) { (title, message, result) -> Void in
                SwiftSpinner.hide()
                // create alert controller
                let myAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                // add "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
                if result { //message sent
                    self.designButton.enabled = false
                    self.designButton.backgroundColor = Colors.darkGrey
                } else { //error
                    self.designButton.setTitle("Réessayer", forState: UIControlState.Normal)
                }
                
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        self.designButton.setTitle("Envoyé", forState: UIControlState.Disabled)
        self.view!.backgroundColor = Colors.greyBackground
        self.title = "Feedback"
        self.feedback.text = "Taper votre feedback ici :"
        self.feedback.textColor = UIColor.lightGrayColor()
        self.designButton.layer.cornerRadius = 6
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = Colors.greenLogo
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

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
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Cancel, handler: nil))
        // add "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.topics[row]
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
            textView.text = "Taper votre feedback ici :"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
        // We do not want UITextField to insert line-breaks.
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }


}