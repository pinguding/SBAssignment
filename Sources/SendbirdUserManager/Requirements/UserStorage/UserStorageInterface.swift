//
//  File.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/17/24.
//

import Foundation
import OrderedCollections

public final class SBUserStorageInterface: SBUserStorage {
    
    private var users: OrderedDictionary<String, SBUser> = .init()
    
    private let lock: NSLocking = NSRecursiveLock()
    
    public func upsertUser(_ user: SBUser) {
        defer { lock.unlock() }
        lock.lock()
        users[user.userId] = user
    }
    
    public func getUsers() -> [SBUser] {
        defer { lock.unlock() }
        lock.lock()
        return users.values.elements
    }
    
    public func getUsers(for nickname: String) -> [SBUser] {
        defer { lock.unlock() }
        lock.lock()
        return users.values.filter { $0.userId == nickname }
    }
    
    public func getUser(for userId: String) -> (SBUser)? {
        defer { lock.unlock() }
        lock.lock()
        return users[userId]
    }
}

