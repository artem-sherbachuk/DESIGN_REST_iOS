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
    func asURLRequest() throws -> URLRequest {
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        return try JSONEncoding.default.encode(urlRequest, with: parameters)
    }
    
    
    static let baseURLString = "https://api.github.com/"
    
    
    case getPublic(String?)
    case getMyStarted()
    
    
    private var method: HTTPMethod {
        switch self {
        case .getPublic, .getMyStarted:
            return .get
        }
    }
    
    private var url: URL {
        
        let casePath: String
        switch self {
        case .getPublic(let nextPageURL):
            if let nextPageURL = nextPageURL { //if alredy have url to next page then don't construct it
                return URL(string: nextPageURL)!
            }
            casePath = "gists/public"
        case .getMyStarted():
            casePath = "gists/starred"
        }
        
        let url = URL(string: GistRouter.baseURLString)!.appendingPathComponent(casePath)
        return url
    }
    
    private var parameters: [String: Any]? {
        switch self {
        case .getPublic, .getMyStarted():
            return nil
        }
    }
}
