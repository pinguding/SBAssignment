//
//  UserManagerInterface.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/18/24.
//

import Foundation

public final class SBUserManagerInterface: SBUserManager {
    
    public var networkClient: any SBNetworkClient = SBNetworkClientInterface()
    
    public var userStorage: any SBUserStorage = SBUserStorageInterface()
    
    private var applicationId: String?
    
    private var apiToken: String?
    
    private var requestQueue: [any Request] = []
    
    public func initApplication(applicationId: String, apiToken: String) {
        self.applicationId = applicationId
        self.apiToken = apiToken
        self.networkClient = SBNetworkClientInterface()
        self.userStorage = SBUserStorageInterface()
    }
    
    public func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        if let user = userStorage.getUser(for: params.userId) {
            completionHandler?(.failure(SBUserManagerError.userCreateFailureAlreadyExist))
            return
        }
        
        guard let applicationId = applicationId, let apiToken = apiToken else {
            completionHandler?(.failure(SBUserManagerError.applicationIdAndAPITokenNotSpecified))
            return
        }
        
        do {
            let createUserRequest = try CreateUserReqeuest(applicationId: applicationId, apiToken: apiToken, parameters: params)
            networkClient.request(request: createUserRequest) { [weak self] result in
                switch result {
                case let .success(dto):
                    let user = SBUser(userId: dto.userId, nickname: dto.nickname, profileURL: dto.profileUrl)
                    self?.userStorage.upsertUser(user)
                    completionHandler?(.success(user))
                case let .failure(error):
                    completionHandler?(.failure(error))
                }
            }
        } catch let error {
            completionHandler?(.failure(error))
            return
        }
    }
    
    public func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        
    }
    
    public func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
        
    }
    
    public func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
        
    }
    
    public func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        
    }
}
