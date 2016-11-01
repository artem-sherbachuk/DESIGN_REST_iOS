//
//  Gist.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 11/1/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import Foundation

class Gist {
    var id: String?
    var description: String?
    var ownerLogin: String?
    var ownerAvatar: String?
    var url: String?
    
    required init() {
        
    }
    
    required init?(json: [String: Any]) {
        guard let description = json["description"] as? String,
        let idValue = json["id"] as? String,
        let url = json["url"] as? String else { return nil }
        
        self.description = description
        self.id = idValue
        self.url = url
        
        if let ownerJson = json["owner"] as? [String: Any] {
            self.ownerLogin = ownerJson["login"] as? String
            self.ownerAvatar = ownerJson["avatar_url"] as? String
        }
    }
}
