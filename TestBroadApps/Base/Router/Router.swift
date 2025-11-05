//
//  Router.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI

enum AppRoute: Hashable {
    case seeAll(TemplateCategory)
    case photoGen(String?, String?, Int?)
    case createAvatar
    case result(String?)
    case rateApp
}

enum GlobalOverlay: Equatable {
    case none
    case chatSidebar
}

@MainActor
final class Router: ObservableObject {
    @Published var selectedTab: Tab = .samples
    @Published var isTabBarHidden: Bool = false
    @Published var isSlideBarShown: Bool = false

    @Published var effectsPath = NavigationPath()
    @Published var aiPhotoPath = NavigationPath()
    @Published var historyPath = NavigationPath()
    @Published var settingsPath = NavigationPath()

    // ГЛОБАЛЬНЫЕ ОВЕРЛЕИ
    @Published var overlay: GlobalOverlay = .none
    func present(_ overlay: GlobalOverlay) { withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { self.overlay = overlay } }
    func dismissOverlay() { withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { self.overlay = .none } }

    
    var avatarVM: CreateAvatarViewModel?
    
    // MARK: - Навигация
    func push(_ route: AppRoute, in tab: Tab? = nil) {
        withAnimation(.easeInOut) { isTabBarHidden = true }

        switch tab ?? selectedTab {
        case .samples: effectsPath.append(route)
        case .chat: aiPhotoPath.append(route)
        case .history: historyPath.append(route)
        case .settings: settingsPath.append(route)
        }
    }

    func pop(in tab: Tab? = nil) {
        switch tab ?? selectedTab {
        case .samples: if !effectsPath.isEmpty { effectsPath.removeLast() }
        case .chat: if !aiPhotoPath.isEmpty { aiPhotoPath.removeLast() }
        case .history: if !historyPath.isEmpty { historyPath.removeLast() }
        case .settings: if !settingsPath.isEmpty { settingsPath.removeLast() }
        }
        
        if allPathsAreEmpty() {
            withAnimation(.easeInOut) { isTabBarHidden = false }
        }
    }

    func popToRoot(in tab: Tab? = nil) {
        
        withAnimation(.easeInOut) { isTabBarHidden = false }

        switch tab ?? selectedTab {
        case .samples: effectsPath.removeLast(effectsPath.count)
        case .chat:
            aiPhotoPath.removeLast(aiPhotoPath.count)
            selectedTab = .samples
        case .history: historyPath.removeLast(historyPath.count)
        case .settings: settingsPath.removeLast(settingsPath.count)
        }
    }
    
    private func allPathsAreEmpty() -> Bool {
        effectsPath.isEmpty && aiPhotoPath.isEmpty && historyPath.isEmpty && settingsPath.isEmpty
    }
}

extension Router {
    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case .seeAll(let category):
            SeeAllView(
                viewModel: SeeAllViewModel(items: category.templates, router: self),
                category: category
            )
        case .photoGen(let item, let prompt, let id):
            PhotoGenView(router: self, photo: item, prompt: prompt, templateId: id)
        case .createAvatar:
            if let avatarVM = avatarVM {
                CreateAvatarView(viewModel: avatarVM)
            }
        case .result(let result):
            ResultView(viewModel: ResultViewModel(result: result, router: self))
        case .rateApp:
            RateAppView(router: self)
        }
    }
}
