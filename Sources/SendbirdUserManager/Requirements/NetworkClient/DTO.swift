//
//  File.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/17/24.
//

import Foundation

/// 서버로부터 User에 대한 정보가 담긴 데이터를 디코딩하기 위한 DTO 객체
internal struct SBUserDTO: Codable {

    let userId: String
    let nickname: String?
    let profileUrl: String?
    
    /// DTO 와 SDK 사용자가 쓸 SBUser 객체로 변환 시켜주는 로직
    func convertToUser() -> SBUser {
        SBUser(userId: userId, nickname: nickname, profileURL: profileUrl)
    }
}

/// 여러 유저정보를 받아오기 위한 DTO 객체
internal struct SBUserListDTO: Decodable {
    let users: [SBUserDTO]
}

/// 서버로부터 Response Error를 받아오기 위한 객체
/// - Parameters:
///    - error: Bool type, error Case 인경우 true
///    - message: Error에 대한 상세 내용이 담겨져있다.
///    - code: 구체적인 에러형태를 분류하기 위한 error Code. https://sendbird.com/docs/chat/platform-api/v3/error-codes 에서 자세한 에러코드들을 확인할 수 있다.
public struct SBResponseErrorData: Decodable {
    let error: Bool
    let message: String
    let code: Int
}
