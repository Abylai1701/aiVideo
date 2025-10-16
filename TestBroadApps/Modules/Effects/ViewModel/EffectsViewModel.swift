//
//  EffectsViewModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import Combine
import SwiftUI

final class EffectsViewModel: ObservableObject {
    private let router: Router
    private let services: ServiceLayer
    private let purchaseManager = PurchaseManager.shared

    @Published var categories: [TemplateCategory] = []
    @Published var showPaywall = false

    init(router: Router, services: ServiceLayer) {
        self.router = router
        self.services = services

        Task(priority: .userInitiated) {
            await services.templateManager.prepareTemplates()
            await MainActor.run {
                self.categories = services.templateManager.getTemplates()
                checkPaywallCondition()
            }
        }
    }

    @MainActor
    private func checkPaywallCondition() {
        if !purchaseManager.isSubscribed {
            print("🟠 Нет подписки — показываем Paywall")
            showPaywall = true
        } else {
            print("🟢 У пользователя активная подписка — Paywall не показываем")
        }
    }
    
    @MainActor
    func seeAll(category: TemplateCategory) {
        router.push(.seeAll(category))
    }

    @MainActor
    func tapItem(item: Template) {
        if PurchaseManager.shared.isSubscribed {
            let url = item.preview
            router.push(.photoGen(url, item.promptTemplate, item.id))
        } else {
            self.showPaywall = true
        }
    }
}
