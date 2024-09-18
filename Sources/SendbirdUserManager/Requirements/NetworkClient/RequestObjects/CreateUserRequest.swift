//
//  CreateUserRequest.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/17/24.
//

import Foundation

struct CreateUserReqeuest: Request {
    
    typealias Response = SBUserDTO
    
    var applicationId: String
    
    var method: SBHTTPMethod {
        .POST
    }
    
    var path: String {
        "/users"
    }
    
    var headerFields: [String : String]
    
    var body: Data?
    
    var queryItems: [URLQueryItem]?
    
    init(applicationId: String, apiToken: String, parameters: UserCreationParams) throws {
        self.applicationId = applicationId
        self.headerFields = ["api-token": apiToken]
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let bodyObject = SBUserDTO(userId: parameters.userId, nickname: parameters.nickname, profileUrl: parameters.profileURL ?? "")
        
        do {
            self.body = try encoder.encode(bodyObject)
        } catch {
            throw RequestError.httpBodyEncodingFailure
        }
    }
}

