//
//  UpdateUserRequest.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/17/24.
//

import Foundation

struct UpdateUserReqeuest: Request {
    
    typealias Response = SBUserDTO
    
    var applicationId: String
    
    var method: SBHTTPMethod {
        .PUT
    }
    
    var userId: String
    
    var path: String {
        "/users/\(userId)"
    }
    
    var headerFields: [String : String]
    
    var body: Data?
    
    var queryItems: [URLQueryItem]?
    
    init(applicationId: String, apiToken: String, user: SBUser) throws {
        self.applicationId = applicationId
        self.headerFields = ["api-token": apiToken]
        self.userId = user.userId
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let bodyObject = SBUserDTO(userId: user.userId, nickname: user.nickname, profileUrl: user.profileURL)
        
        do {
            self.body = try encoder.encode(bodyObject)
        } catch {
            throw RequestError.httpBodyEncodingFailure
        }
    }
}

