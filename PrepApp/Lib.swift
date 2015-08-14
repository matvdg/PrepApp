//
//  Lib.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 06/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

extension Array {
    mutating func shuffle() {
        if count < 2 { return }
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

extension String {
    
	func sha1() -> String {
		let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
		var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
		CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
		let hexBytes = map(digest) { String(format: "%02hhx", $0) }
		return "".join(hexBytes)
	}
	
	func toBool() -> Bool? {
		switch self {
		case "True", "true", "yes", "1":
			return true
		case "False", "false", "no", "0":
			return false
		default:
			return nil
		}
	}
	
	func hasUppercase() -> Bool {
		var result = false
		for chr in self {
			var str = String(chr)
			if str.lowercaseString != str {
				result = true
			}
		}
		return result
	}
	
	func hasTwoNumber() -> Bool {
		var result: Int = 0
		for chr in self {
			var str = String(chr)
			if let figure: Int = str.toInt() {
				result++
			}
		}
		if (result >= 2){
			return true
		} else {
			return false
		}
	}
	
	func hasGoodLength()-> Bool {
		if count(self) >= 8 {
			return true
		} else {
			return false
		}
	}
    
    
}
