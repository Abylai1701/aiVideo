//
//  AvatarModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//

import Foundation

struct GenerationResponse: Codable, Identifiable, Hashable {
    let id: String
    let type: String?
    let status: String
    let result: String?
    let error: String?
}

struct HistoryResponse: Codable {
    let items: [GenerationResponse]
    let total: Int
}

struct UserAvatar: Codable, Identifiable {
    let id: Int
    let title: String?
    let preview: String?
    let gender: String?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, preview, gender
        case isActive = "is_active"
    }
}
