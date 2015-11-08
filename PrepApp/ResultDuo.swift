//
//  ResultDuo.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 07/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

class Result {
    
    var id: Int
    var firstName: String
    var lastName: String
    var nickname: String
    var score: Int
    
    init(id: Int, firstName: String, lastName: String, nickname: String, score: Int) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.nickname = nickname
        self.score = score
    }
    
}

class ResultDuo {
    
    var idDuo: Int
    var resultDuo: [Result]
    
    init(idDuo: Int, resultDuo: [Result]) {
        self.idDuo = idDuo
        self.resultDuo = resultDuo
    }
    
    static func hydrateResultDuo(data: NSArray) -> [Result] {
        var response = [Result]()
        for element in data {
            if let dico = element as? NSDictionary {
                let id = dico["id"] as! Int
                let firstName = dico["firstName"] as! String
                let lastName = dico["lastName"] as! String
                let nickname = dico["nickname"] as! String
                let score = dico["score"] as! Int
                let result = Result(id: id, firstName: firstName, lastName: lastName, nickname: nickname, score: score)
                response.append(result)
            }
        }
        return response
    }
}
