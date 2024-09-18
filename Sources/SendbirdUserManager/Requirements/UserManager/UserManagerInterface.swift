//
//  UserManagerInterface.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/18/24.
//

import Foundation
import OrderedCollections

public final class SBUserManagerInterface: SBUserManager {
    
    public var networkClient: any SBNetworkClient = SBNetworkClientInterface()
    
    public var userStorage: any SBUserStorage = SBUserStorageInterface()
    
    private var applicationId: String?
    
    private var apiToken: String?
    
    private var requestQueue: [any Request] = []
    
    private let userCreationRateLimit: Int = 10
    
    private var currentUserCreateRate: Int = 0
    
    public func initApplication(applicationId: String, apiToken: String) {
        self.applicationId = applicationId
        self.apiToken = apiToken
        self.networkClient = SBNetworkClientInterface()
        self.userStorage = SBUserStorageInterface()
    }
    
    public func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        guard let applicationId = applicationId, let apiToken = apiToken else {
            completionHandler?(.failure(SBUserManagerError.applicationIdAndAPITokenNotSpecified))
            return
        }
        
        if params.userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            completionHandler?(.failure(SBUserManagerError.emptyUserId))
            return
        }
        
        if userStorage.getUser(for: params.userId) != nil {
            completionHandler?(.failure(SBUserManagerError.userCreateFailureAlreadyExist))
            return
        }
        
        if userCreationRateLimit <= currentUserCreateRate {
            completionHandler?(.failure(SBUserManagerError.maximumUserCreationLimitExceeded))
            return
        }
        
        self.currentUserCreateRate += 1
        
        do {
            let createUserRequest = try CreateUserReqeuest(applicationId: applicationId, apiToken: apiToken, parameters: params)
            networkClient.request(request: createUserRequest) { [weak self] result in
                self?.currentUserCreateRate -= 1
                do {
                    let user = try result.get().convertToUser()
                    completionHandler?(.success(user))
                    self?.userStorage.upsertUser(user)
                } catch let error {
                    completionHandler?(.failure(error))
                }
            }
            
            self.userStorage.upsertUser(SBUser(userId: params.userId, nickname: params.nickname, profileURL: params.profileURL))
            
        } catch let error {
            completionHandler?(.failure(error))
        }
    }
    
    public func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        guard params.count <= userCreationRateLimit else {
            completionHandler?(.failure(SBUserManagerError.maximumUserCreationLimitExceeded))
            return
        }

        var createdUsers: [SBUser] = []
        var errorList: [any Error] = []
        for param in params {
            createUser(params: param) { result in
                switch result {
                case let .success(user):
                    createdUsers.append(user)
                case let .failure(error):
                    errorList.append(error)
                }
                
                if createdUsers.count + errorList.count == params.count {
                    if errorList.isEmpty {
                        completionHandler?(.success(createdUsers))
                    } else {
                        let failedCreateUsers: [SBUser] = params.map {
                            SBUser(userId: $0.userId, nickname: $0.nickname, profileURL: $0.profileURL)
                        }.filter { param in
                            !createdUsers.contains { $0.userId == param.userId }
                        }
                        completionHandler?(.failure(SBUserManagerError.failedToCreateAllUsers(successUserId: createdUsers.map { $0.userId}, failedUserId: failedCreateUsers.map { $0.userId })))
                    }
                }
            }
        }
    }
    
    public func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
        guard let applicationId = applicationId, let apiToken = apiToken else {
            completionHandler?(.failure(SBUserManagerError.applicationIdAndAPITokenNotSpecified))
            return
        }
        
        if params.userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            completionHandler?(.failure(SBUserManagerError.emptyUserId))
            return
        }

        do {
            let updateRequest = try UpdateUserReqeuest(applicationId: applicationId, apiToken: apiToken, parameters: params)
            networkClient.request(request: updateRequest) { [weak self] result in
                switch result {
                case let .success(dto):
                    let user = dto.convertToUser()
                    completionHandler?(.success(user))
                    self?.userStorage.upsertUser(user)
                case let .failure(error):
                    completionHandler?(.failure(error))
                }
                
            }
            userStorage.upsertUser(SBUser(userId: params.userId, nickname: params.nickname, profileURL: params.profileURL))
        } catch let error {
            completionHandler?(.failure(error))
        }
    }
    
    public func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
        guard let applicationId = applicationId, let apiToken = apiToken else {
            completionHandler?(.failure(SBUserManagerError.applicationIdAndAPITokenNotSpecified))
            return
        }
        
        if userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            completionHandler?(.failure(SBUserManagerError.emptyUserId))
            return
        }
        
        if let user = userStorage.getUser(for: userId) {
            completionHandler?(.success(user))
            return
        }
        
        let getUserRequest = GetUserReqeuest(applicationId: applicationId, apiToken: apiToken, userId: userId)
        
        networkClient.request(request: getUserRequest) { [weak self] result in
            switch result {
            case let .success(dto):
                let user = dto.convertToUser()
                completionHandler?(.success(user))
                self?.userStorage.upsertUser(user)
            case let .failure(error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    public func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        guard let applicationId = applicationId, let apiToken = apiToken else {
            completionHandler?(.failure(SBUserManagerError.applicationIdAndAPITokenNotSpecified))
            return
        }
        
        if nicknameMatches.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            completionHandler?(.failure(SBUserManagerError.emptyNicknameMatches))
            return
        }
        
        let getUserListRequest = GetUserListReqeuest(applicationId: applicationId,
                                                     apiToken: apiToken,
                                                     limit: 100,
                                                     nickname: nicknameMatches)
        
        networkClient.request(request: getUserListRequest) { [weak self] result in
            switch result {
            case let .success(dto):
                let users = dto.users.map { $0.convertToUser() }
                completionHandler?(.success(users))
                users.forEach { user in
                    self?.userStorage.upsertUser(user)
                }
            case let .failure(error):
                completionHandler?(.failure(error))
            }
        }
    }
}
