//
//  File.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/17/24.
//

import Foundation

public final class SBUserStorageInterface: SBUserStorage {
    
    private var users: [String: (index: Int, user: SBUser)] = [:]
    
    private var userArray: [SBUser] = []
    
    private let lock: NSLocking = NSRecursiveLock()
    
    public func upsertUser(_ user: SBUser) {
        defer { lock.unlock() }
        lock.lock()
        if let userContext = users[user.userId] {
            let index = userContext.index
            users[user.userId] = (index, user)
            userArray[index] = user
        } else {
            let index = users.count
            users[user.userId] = (index, user)
            userArray.append(user)
        }
    }
    
    public func getUsers() -> [SBUser] {
        defer { lock.unlock() }
        lock.lock()
        return userArray
    }
    
    public func getUsers(for nickname: String) -> [SBUser] {
        defer { lock.unlock() }
        lock.lock()
        return userArray.filter{ $0.nickname == nickname }
    }
    
    public func getUser(for userId: String) -> (SBUser)? {
        defer { lock.unlock() }
        lock.lock()
        return users[userId]?.1
    }
}

