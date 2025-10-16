//
//  HapticManager.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 12.10.2025.
//

import Foundation
import SwiftUI

final class HapticFeedbackManager {

    enum Pattern {
        case soft
        case low
        case medium
        case strong
    }

    // MARK: - Public Properties

    static let shared = HapticFeedbackManager()

    // MARK: - Private Properties

    private let softGenerator  = UIImpactFeedbackGenerator(style: .soft)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)

    // MARK: - Init

    private init() {
        softGenerator.prepare()
        heavyGenerator.prepare()
    }

    // MARK: - Public Methods

    func trigger(_ pattern: Pattern = .soft) {
        switch pattern {
        case .soft:
            softGenerator.impactOccurred()
        case .low:
            heavyGenerator.impactOccurred(intensity: 0.3)
        case .medium:
            heavyGenerator.impactOccurred(intensity: 0.5)
        case .strong:
            heavyGenerator.impactOccurred(intensity: 0.7)
        }
    }
}
