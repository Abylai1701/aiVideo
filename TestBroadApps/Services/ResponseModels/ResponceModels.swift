//
//  ResponceModels.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//

import Foundation

struct UserResponse: Codable {
    let id: String
    let apphud_id: String
    let tokens: Int?
    let avatar_tokens: Int?
}

struct AuthResponse: Codable {
    let accessToken: String
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}
