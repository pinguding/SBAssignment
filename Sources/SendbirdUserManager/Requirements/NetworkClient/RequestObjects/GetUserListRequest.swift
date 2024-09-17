//
//  GetUserListRequest.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/17/24.
//

import Foundation

struct GetUserListReqeuest: Request {
    
    typealias Response = SBUserListDTO
    
    var applicationId: String
    
    var method: SBHTTPMethod {
        .GET
    }
    
    var path: String {
        "/users"
    }
    
    var headerFields: [String : String]
    
    var body: Data? {
        nil
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    init(applicationId: String, apiToken: String) {
        self.applicationId = applicationId
        self.headerFields = ["api-token": apiToken]
    }
}
