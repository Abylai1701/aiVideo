//
//  EffectsModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import Foundation

struct PhotoCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let items: [PhotoItem]
}

struct PhotoItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
//    let imageURL: URL
    let imageURL: String
}
