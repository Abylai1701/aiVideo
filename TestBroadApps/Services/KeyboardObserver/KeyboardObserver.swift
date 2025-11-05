//
//  KeyboardObserver.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 03.11.2025.
//

import Foundation
import SwiftUI
import Combine

final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        Publishers.Merge(willShow, willHide)
            .receive(on: RunLoop.main)
            .assign(to: &$height)
    }
}
