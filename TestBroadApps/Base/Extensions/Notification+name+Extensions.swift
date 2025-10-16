//
//  Notification+name+Extensions.swift
//  WeatherPoetry
//
//  Created by Abylaikhan Abilkayr on 05.08.2025.
//

import Foundation

extension Notification.Name {
    static let didFinishOnboarding = Notification.Name("didFinishOnboarding")
    static let didFinishAvatarCreate = Notification.Name("didFinishAvatarCreate")
    static let didFinishGenerate = Notification.Name("didFinishGenerate")
    
    static let openGenerationFromNotification = Notification.Name("openGenerationFromNotification")
}
