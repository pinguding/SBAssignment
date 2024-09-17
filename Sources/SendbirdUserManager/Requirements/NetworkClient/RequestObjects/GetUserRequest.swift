//
//  GetUserRequest.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/17/24.
//

import Foundation

struct GetUserReqeuest: Request {
    
    typealias Response = SBUserDTO
    
    var applicationId: String
    
    var method: SBHTTPMethod {
        .GET
    }
    
    var userId: String
    
    var path: String {
        "/users/\(userId)"
    }
    
    var headerFields: [String : String]
    
    var body: Data? {
        nil
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    init(applicationId: String, apiToken: String, userId: String) {
        self.applicationId = applicationId
        self.headerFields = ["api-token": apiToken]
        self.userId = userId
    }
}
