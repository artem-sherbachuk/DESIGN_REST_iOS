//
//  GitHubAPIService.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 11/1/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import Foundation
import Alamofire

class GitHubAPIService {
    static let sharedInstance = GitHubAPIService()
    
    func printPublicGist() {
        Alamofire.request(GistRouter.getPublic()).responseString { response in
            if let responseString = response.result.value {
                print(responseString)
            }
        }
    }
}
