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
    
    public var errorDescription: String? {
        switch self {
        case .applicationIdAndAPITokenNotSpecified:
            return "Before request, applicationId and api token must set. Please initApplication first."
        case .userCreateFailureAlreadyExist:
            return "User ID is already exist. Please check again user id, target user already created or use `updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?)` functions"
        case .maximumUserCreationLimitExceeded:
            return "You can create maximum 10 users at one time. If you want to create more than 10 users, please call `createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?)` function mulitple times"
        }
    }
}
