//
//  FactoryHistory.swift
//  PrepApp
//
//  Created by Mikael Vandeginste on 08/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class FactoryHistory {
    
    static let history = History()
    static let scoring = Scoring()
    
    class func getHistory() -> History {
        return history
    }
    
    class func getScoring() -> Scoring {
        return scoring
    }
    
}
