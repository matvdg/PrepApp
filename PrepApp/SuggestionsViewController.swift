//
//  SuggestionsViewController.swift
//  PrepApp
//
//  Created by Mikael Vandeginste on 15/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class SuggestionsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    
    var topics = ["Une suggestion/idée", "Un bug/remarque", "Une nouvelle fonctionnalité", "Un autre commentaire"]
    
    
    @IBOutlet weak var topicsPicker: UIPickerView!
    @IBOutlet weak var designButton: UIButton!
    @IBOutlet weak var remark: UITextView!

    @IBAction func send(sender: AnyObject) {
        self.sendRemark()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Suggestions/Remarques"
        self.remark.text = "Taper votre commentaire ici :"
        self.remark.textColor = UIColor.lightGrayColor()
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

    func sendRemark() {
        println("coucou")
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
            textView.text = "Taper votre commentaire ici :"
            textView.textColor = UIColor.lightGrayColor()
        }
    }




}
