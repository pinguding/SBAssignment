//
//  File.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/17/24.
//

import Foundation

internal struct SBUserDTO: Codable {
    let userId: String
    let nickname: String?
    let profileUrl: String?
}

internal struct SBUserListDTO: Decodable {
    let users: [SBUserDTO]
}

public struct SBResponseErrorData: Decodable {
    let error: Bool
    let message: String
    let code: Int
}
