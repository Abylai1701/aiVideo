//
//  ChatModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 03.11.2025.
//

import Foundation
import SwiftUI

struct Message: Identifiable, Codable {
    let id: UUID
    var text: String
    var isUser: Bool
    var imageData: Data?
    var createdAt: Date = Date()
    
    init(text: String, isUser: Bool, imageData: Data? = nil) {
        self.id = UUID()
        self.text = text
        self.isUser = isUser
        self.imageData = imageData
    }
}



struct Chat: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    var title: String
    var messages: [Message]
    
    init(title: String, messages: [Message] = []) {
        self.id = UUID()
        self.title = title
        self.messages = messages
    }
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
