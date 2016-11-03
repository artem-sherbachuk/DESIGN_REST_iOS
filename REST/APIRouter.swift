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
    
    
    private var method: HTTPMethod {
        switch self {
        case .getPublic:
            return .get
        }
    }
    
    private var url: URL {
        let publicPath: String
        switch self {
        case .getPublic(let nextPageURL):
            if let nextPageURL = nextPageURL { //if alredy have url to next page then don't construct it
                return URL(string: nextPageURL)!
            }
            publicPath = "gists/public"
        }
        let url = URL(string: GistRouter.baseURLString)!.appendingPathComponent(publicPath)
        return url
    }
    
    private var parameters: [String: Any]? {
        switch self {
        case .getPublic:
            return nil
        }
    }
}
