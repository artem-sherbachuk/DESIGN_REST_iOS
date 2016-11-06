//
//  Gist.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 11/1/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import Foundation

struct Gist {
    var id: String?
    var description: String?
    var ownerLogin: String?
    var ownerAvatar: String?
    var url: String?
    var files: [File]?
    
    init(){}
    init?(json: [String: Any]) {
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
        
        self.files = [File]()
        if let fileJSON = json["files"] as? [String: [String: Any]] {
            fileJSON.forEach{ _, fileJSON in
                if let newFile = File(json: fileJSON) {
                    self.files?.append(newFile)
                }
            }
        }
    }
}

struct File {
    var fileName: String?
    var rawURL: String?
    
    init() {}
    init?(json: [String: Any]) {
        self.fileName = json["filename"] as? String
        self.rawURL = json["raw_url"] as? String
    }
}
