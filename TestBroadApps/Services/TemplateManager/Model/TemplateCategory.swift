//
//  TemplateCategory.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//

import Foundation

struct TemplateCategory: Codable, Identifiable, Hashable {
    let id: Int
    let title: String?
    let description: String?
    let preview: String?
    let avatar1Preview: String?
    let avatar2Preview: String?
    let previewWoman: String?
    let previewMan: String?
    let code: String?
    let isNew: Bool?
    let isCouple: Bool?
    let isGirlfriends: Bool?
    let groupPreview: GroupPreview?
    let previewByGender: PreviewByGender?
    let totalTemplates: Int?
    let totalUsed: Int?
    let templates: [Template]
}

struct GroupPreview: Codable, Hashable {
    let gorup1: [String]?
    let gorup2: [String]?
    let gorup3: [String]?
}

struct PreviewByGender: Codable, Hashable {
    let f: GenderPreview?
    let m: GenderPreview?
}

struct GenderPreview: Codable, Hashable {
    let group1: [String]?
    let group2: [String]?
    let group3: [String]?
}

struct Template: Codable, Identifiable, Hashable {
    let id: Int
    let title: String?
    let preview: String?
    let previewProduction: String?
    let avatar1preview: String?
    let avatar2preview: String?
    let videoPreview: String?
    let prompt: String?
    let gender: String?
    let promptTemplate: String?
    let videoPrompt: String?
    let isEnabled: Bool?
}
