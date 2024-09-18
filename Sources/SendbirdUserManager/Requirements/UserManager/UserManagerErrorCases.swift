//
//  UserManagerErrorCases.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/18/24.
//

import Foundation

public enum SBUserManagerError: LocalizedError {
    case applicationIdAndAPITokenNotSpecified
    case userCreateFailureAlreadyExist
    case maximumUserCreationLimitExceeded
    case failedToCreateAllUsers(successUserId: [String], failedUserId: [String])
    case emptyUserId
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
