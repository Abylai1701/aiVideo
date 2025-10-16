//
//  SettingsModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 11.10.2025.
//

import Foundation

struct UpdateAvatarRequest: Encodable {
    let gender: String
    let title: String
    let avatarId: String
    let isActive: Bool
}
