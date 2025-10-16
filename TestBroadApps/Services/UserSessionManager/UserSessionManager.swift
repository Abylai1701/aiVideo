//
//  UserSessionManager.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//

import Foundation

final class UserSessionManager {

    static let shared = UserSessionManager()

    private let userIdKey = "user_id"
    private let tokenKey = "access_token"

    var userId: String? {
        UserDefaults.standard.string(forKey: userIdKey)
    }

    var accessToken: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    func saveUser(id: String, token: String) {
        UserDefaults.standard.setValue(id, forKey: userIdKey)
        UserDefaults.standard.setValue(token, forKey: tokenKey)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
