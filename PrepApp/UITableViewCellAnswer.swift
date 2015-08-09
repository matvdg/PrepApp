//
//  UITableViewCellAnswer.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 08/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class UITableViewCellAnswer: UITableViewCell {
    
    var number: UILabel!
    var answer: UIWebView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.number = UILabel(frame: CGRectMake(0, 0, 40, 40))
        self.answer = UIWebView(frame: CGRectMake(40, 0, 260, 40))
        self.addSubview(self.number)
        self.addSubview(self.answer)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}