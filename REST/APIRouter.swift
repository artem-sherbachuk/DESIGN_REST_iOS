//
//  APIRouter.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 11/1/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import Foundation
import Alamofire

enum GistRouter: URLRequestConvertible {
    
    case getPublic()
    case getUserGists()
    case getStarredGists()
    case basicAuth(user: String, passord: String)
    case OAuth2(clientID: String, clientSecret: String, code: String)
    
    private static let baseURLString = "https://api.github.com/"
    private static let OAuthPath = "https://github.com/login/oauth/access_token"
    
    
    //MARK: - URLRequest generation
    //--------------------------------------------------------------------------//
    
    private var method: HTTPMethod {
        switch self {
        case .getPublic, .basicAuth, .getUserGists, .getStarredGists:
            return .get
        case .OAuth2:
            return .post
        }
    }
    
    private var url: URL {
        
        let casePath: String
        switch self {
        case .getPublic:
            if let nextPageURL = GitHubAPIService.sharedInstance.nextGistsPageURL { //if alredy have url to next page then don't construct it
                return URL(string: nextPageURL)!
            }
            casePath = "gists/public"
        case .basicAuth, .getUserGists:
            casePath = "gists"
        case .getStarredGists:
            casePath = "gists/starred"
        case .OAuth2:
            return URL(string: GistRouter.OAuthPath)!
        }
        
        let url = URL(string: GistRouter.baseURLString)!.appendingPathComponent(casePath)
        return url
    }
    
    private var parameters: [String: Any]? {
        switch self {
        case .getPublic, .basicAuth, .getUserGists, .getStarredGists:
            return nil
        case .OAuth2(let clientID, let clientSecret, let code):
            return  ["client_id": clientID,
                     "client_secret": clientSecret,
                     "code": code]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .basicAuth(let username, let password):
            if let credentialData = "\(username):\(password)".data(using: String.Encoding.utf8) {
                let base64Credentials = credentialData.base64EncodedString()
                urlRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            }
        case .OAuth2:
            return try URLEncoding.default.encode(urlRequest, with: parameters) //request to get OAuth2 token
        default: break
        }
        
        if let OAuth2Token = GitHubAPIService.getOAuth2Token() { //if have OAuth2 accsess token inject it for every API call
            urlRequest.setValue("token \(OAuth2Token)", forHTTPHeaderField: "Authorization")
        }
        
        return try JSONEncoding.default.encode(urlRequest, with: parameters)
    }
}
