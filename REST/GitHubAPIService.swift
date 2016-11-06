//
//  GitHubAPIService.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 11/1/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import Foundation
import Alamofire
import SafariServices
import Locksmith

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
    case objectSerialization(reason: String)
}

final class GitHubAPIService: NSObject {
    static let sharedInstance = GitHubAPIService()
    private(set) var isLoading = false
    
    
    //MARK: - Fetch Gists
    //---------------------------------------------------------------------------------//
    
    private(set) var nextGistsPageURL: String?
    
    typealias FetchGistsCompletion = (Result<[Gist]>) -> Void
    
    static func fetchGists(url: URLRequestConvertible, completion: @escaping FetchGistsCompletion) {
        let service = GitHubAPIService.sharedInstance
        if GitHubAPIService.sharedInstance.isLoading {return} //don't try load if loading not ended
        service.isLoading = true
        Alamofire.request(url).responseJSON { (response) in
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
        debugPrint(jsonArray)
        let gists = jsonArray.flatMap{ Gist(json: $0) }
        return Result.success(gists)
    }
    
    
    //MARK: - Cache
    //---------------------------------------------------------------------------------//
    static func clearAllCache() {
        let service = GitHubAPIService.sharedInstance
        service.nextGistsPageURL = nil
        let cashe = URLCache.shared
        cashe.removeAllCachedResponses()
    }
    
    
    //MARK: - OAuth2
    //---------------------------------------------------------------------------------//
    private static let clientID = "e1af210403d248c875c0"
    private static let clientSecret = "c109ebdeed7636e133c076c8dc8f25cfe4713a32"
    
    fileprivate weak var safariVC: SFSafariViewController?
    
    typealias OAuthCompletion = (Error?) -> Void
    private var oauthCompletion: OAuthCompletion?
    
    private var OAuthToken: String? {
        set {
            guard let newValue = newValue else {
                let _ = try? Locksmith.deleteDataForUserAccount(userAccount: "github")
                return
            }
            guard let _ = try? Locksmith.updateData(data: ["token": newValue], forUserAccount: "github") else {
                                                        let _ = try? Locksmith.deleteDataForUserAccount(userAccount: "github")
                                                        return
            }
        }
        get {
            let dictionary = Locksmith.loadDataForUserAccount(userAccount: "github")
            return dictionary?["token"] as? String
        }
    }
    
    
    static func isHasOAuthToken() -> Bool {
        return GitHubAPIService.sharedInstance.OAuthToken != nil
    }
    
    static func getOAuth2Token() -> String? {
        return GitHubAPIService.sharedInstance.OAuthToken
    }
    
    
    static func OAuth2Login(fromVC: UIViewController, completion: @escaping OAuthCompletion) {
        let service = GitHubAPIService.sharedInstance
        
        let actionSheet = UIAlertController(title: "Github Authorization",
                                            message: "You must authorize to be able use advanced feature of this app",
                                            preferredStyle: .actionSheet)
        let gitOAuth = UIAlertAction(title: "Git OAuth", style: .default) { _ in
            service.oauthCompletion = completion
            let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientID)&scope=gist&state=TEST_STATE")!
            let safariVC = SFSafariViewController(url: authURL)
            service.safariVC = safariVC
            service.safariVC!.delegate = service
            fromVC.present(service.safariVC!, animated: true, completion: nil)
        }
        actionSheet.addAction(gitOAuth)
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            service.oauthCompletion = nil
        }
        actionSheet.addAction(cancel)
        fromVC.present(actionSheet, animated: true, completion: nil)
    }
    
    
    static func processOAuthURLCallback(url: URL) { //exchange callback url code on OAuth2 token
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {return}
        for item in queryItems where item.name.lowercased() == "code" {
            if let code = item.value {
                GitHubAPIService.exchangeCodeOnOAuthToken(code: code)
            }
        }
    }
    private static func exchangeCodeOnOAuthToken(code: String) {
        let urlRequest = GistRouter.OAuth2(clientID: clientID, clientSecret: clientSecret, code: code)
        Alamofire.request(urlRequest)
            .responseString { response in
                let service = GitHubAPIService.sharedInstance
                guard let result = response.result.value, response.result.error == nil else {
                    print("ExchangeCodeOnOAuthToken error: \(response.result.error)")
                    service.oauthCompletion?(response.result.error!)
                    return
                }
                let token = result.replacingOccurrences(of: "access_token=", with: "")
                    .replacingOccurrences(of: "&scope=gist&token_type=bearer", with: "")//remove messy, get token code
                service.OAuthToken = token
                service.oauthCompletion?(nil)
        }
        
    }
}


//MARK: SFSafariViewControllerDelegate
extension GitHubAPIService: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            controller.dismiss(animated: true, completion: nil)
            GitHubAPIService.sharedInstance.safariVC = nil
        }
    }
}
 
