//
//  File.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/17/24.
//

import Foundation

public final class SBUserStorageInterface: SBUserStorage {
    
    private var users: [String: SBUser] = [:]
    
    private var userArray: [SBUser] = []
    
//    private var nicknameMatchedMaps: [String: [SBUser]] = [:]
    
    private let lock: NSLocking = NSRecursiveLock()
    
    public func upsertUser(_ user: SBUser) {
        lock.lock()
        self.users[user.userId] = user
        self.userArray.append(user)
//        if let nickname = user.nickname {
//            if self.nicknameMatchedMaps[nickname] == nil {
//                self.nicknameMatchedMaps[nickname] = [user]
//            } else {
//                self.nicknameMatchedMaps[nickname]?.append(user)
//            }
//        }
        lock.unlock()
    }
    
    public func getUsers() -> [SBUser] {
        lock.lock()
        defer {
            lock.unlock()
        }
        return userArray
    }
    
    public func getUsers(for nickname: String) -> [SBUser] {
        lock.lock()
        defer {
            lock.unlock()
        }
//        return nicknameMatchedMaps[nickname] ?? []
        return userArray.filter{ $0.nickname == nickname }
    }
    
    public func getUser(for userId: String) -> (SBUser)? {
        lock.lock()
        defer {
            lock.unlock()
        }
        return users[userId]
    }
}

