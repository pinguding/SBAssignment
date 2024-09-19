//
//  UserManagerErrorCases.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/18/24.
//

import Foundation

public enum SBUserManagerError: LocalizedError {
    /// SBUserManager 의 initApplication 함수를 통해 Application Id 와 API token을 정의하지 않고 유저를 생성 및 조회할 경우 발생
    case applicationIdAndAPITokenNotSpecified
    /// 새로운 유저를 생성하려고 할때 사용된 user id가 이미 생성된 유저와 동일할 경우 발생
    case userCreateFailureAlreadyExist
    /// 한번에 최대 생성할 수 있는 유저 숫자를 초과한 경우
    case maximumUserCreationLimitExceeded
    /// 여러 유저를 생성할때 부분적 성공이 되었을 경우 성공한 유저와 실패한 유저들의 user id 의 정보를 담고 있는 error.
    /// - Parameters:
    ///    - successUserId: 생성에 성공한 유저들의 User ID
    ///    - failedUserId: 생성에 실패한 유저들의 User ID
    case failedToCreateAllUsers(successUserId: [String], failedUserId: [String])
    /// 유저를 생성 및 조회할때 요청된 user id 값이 empty 이거나 blank 일 경우 발생
    case emptyUserId
    /// nickname 을 이용해 유저들을 조회할때 nickname 값이 empty 이거나 blank 일 경우 발생
    case emptyNicknameMatches
    
    public var errorDescription: String? {
        switch self {
        case .applicationIdAndAPITokenNotSpecified:
            return "Before request, applicationId and api token must set. Please initApplication first."
        case .userCreateFailureAlreadyExist:
            return "User ID is already exist. Please check again user id, target user already created or use `updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?)` functions."
        case .maximumUserCreationLimitExceeded:
            return "You can create maximum 10 users at one time. If you want to create more than 10 users, please call `createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?)` function mulitple times."
        case .failedToCreateAllUsers(let success, let failed):
            let successId: String = success.joined(separator: ", ")
            let failedId: String = failed.joined(separator: ",")
            return "Some users are failed to create.\nSuccess to create users are \(successId)\nFailed to create users are \(failedId).\n Please try again."
        case .emptyUserId:
            return "User Id is blank or empty string. User ID should not be a blank or empty string. Please check about user id."
        case .emptyNicknameMatches:
            return "Nickname is empty string. If you want to search matched nickname users, nickname should not a blank or empty string. Please check again."
        }
    }
}
