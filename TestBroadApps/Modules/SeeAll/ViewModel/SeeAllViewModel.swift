//
//  SeeAllViewModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import Foundation
import ApphudSDK

@MainActor
final class SeeAllViewModel: ObservableObject {
    
    @Published var items: [Template] = []
    @Published var showPaywall = false
    
    private var router: Router
    
    init(items: [Template], router: Router) {
        self.items = items
        self.router = router
    }
    
    func pop() {
        router.pop()
    }
    
    func effectTap(on item: Template) {
        if Apphud.hasPremiumAccess() {
            let url = item.preview
            router.push(.photoGen(url, item.promptTemplate, item.id))
        } else {
            self.showPaywall = true
        }
    }
}
