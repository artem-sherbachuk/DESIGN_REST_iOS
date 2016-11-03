//
//  GitHubAPIService.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 11/1/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import Foundation
import Alamofire

/*
 1. A generic networking error that wraps up another error. That’ll be handy for when Alamofire
 gives us an error
 2. The API gave us an error message in the JSON that it returned
 3. Can’t finish authorization login (e.g., incorrect credentials)
 4. Credentials aren’t valid anymore
 5. Can’t get the data we want out of the JSON
 */
enum GitHubAPIManagerError: Error {
    case netWork(error: Error)
    case apiProviderError(reason: String)
    case authCouldNot(reason: String)
    case objectSerialization(reason: String)
}


final class GitHubAPIService {
    private static let sharedInstance = GitHubAPIService()
    
    private var nextGistsPageURL: String?
    private var isLoading = false
    
    static func fetchPublicGists(completion: @escaping (Result<[Gist]>) -> Void) {
        let service = GitHubAPIService.sharedInstance
        if GitHubAPIService.sharedInstance.isLoading {return} //don't try load if loading not ended
        service.isLoading = true
        Alamofire.request(GistRouter.getPublic(service.nextGistsPageURL)).responseJSON { (response) in
            let result = service.gistArrayFromResponse(response: response)
            service.nextGistsPageURL = service.parseNextPageFromHeaders(response: response.response)
            completion(result)
            service.isLoading = false
        }
    }
    
    private func parseNextPageFromHeaders(response: HTTPURLResponse?) -> String? {
        guard let linksFromHeader = response?.allHeaderFields["Link"] as? String else {return nil}
        let links = linksFromHeader.characters.split{ $0 == ","}.map{String($0)}
        
        for link in links where link.contains("rel=\"next\"") {
            let url = link.replacingOccurrences(of: "<", with: "")
                .replacingOccurrences(of: ">", with: "")
                .replacingOccurrences(of: ";", with: "")
                .replacingOccurrences(of: "rel=\"next\"", with: "")
                .replacingOccurrences(of: " ", with: "")
            return url
        }
        
        return nil
    }
    
    private func gistArrayFromResponse(response: DataResponse<Any>) -> Result<[Gist]> {
        if let error = response.result.error {
            print("response.result.error: \(error)")
            return Result.failure(GitHubAPIManagerError.netWork(error: error))
        }
        
        guard  let jsonArray = response.result.value as? [[String: Any]] else {
            print("didn't get array of gists object as JSON from API")
            return Result.failure(GitHubAPIManagerError.objectSerialization(reason:
                "Did not get JSON dictionary in response"))
        }
        
        // check for "message" errors in the JSON because this API does that
        if let jsonDictionary = response.result.value as? [String: Any],
            let errorMessage = jsonDictionary["message"] as? String {
            return .failure(GitHubAPIManagerError.apiProviderError(reason: errorMessage))
        }
        
        let gists = jsonArray.flatMap{ Gist(json: $0) }
        return Result.success(gists)
    }
}
