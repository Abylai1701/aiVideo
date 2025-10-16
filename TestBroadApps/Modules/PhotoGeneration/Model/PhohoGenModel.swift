//
//  PhohoGenModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 11.10.2025.
//

import Foundation

struct PhotoGodmodeRequest: Encodable {
    let type: String
    let prompt: String
    let avatar_id: Int
    let aspect_ratio: String?
    let template_id: Int?
    let is_free_god_mode: Bool
}
