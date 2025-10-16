//
//  RootView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI
import Combine

struct RootView: View {
    @StateObject var router = Router()
    let services: ServiceLayer
    @State private var cancellables = Set<AnyCancellable>()

    @StateObject private var effectsViewModel: EffectsViewModel
    @StateObject private var historyViewModel: HistoryViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    @StateObject private var aiPhotoViewModel: AiPhotoViewModel
    
    @AppStorage("onboardingСompleted") private var onboardingCompleted = false
    @State private var showOnboarding = false
    
    // MARK: - Init
    init(services: ServiceLayer) {
        self.services = services
        
        let router = Router()
        router.avatarVM = CreateAvatarViewModel(router: router)
        _router = StateObject(wrappedValue: router)
        
        _effectsViewModel = StateObject(
            wrappedValue: EffectsViewModel(router: router, services: services)
        )
        
        _historyViewModel = StateObject(
            wrappedValue: HistoryViewModel(router: router)
        )
        _settingsViewModel = StateObject(
            wrappedValue: SettingsViewModel(router: router)
        )
        _aiPhotoViewModel = StateObject(
            wrappedValue: AiPhotoViewModel(router: router)
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if onboardingCompleted {
                Group {
                    switch router.selectedTab {
                    case .effects:
                        NavigationStack(path: $router.effectsPath) {
                            EffectsView(viewModel: effectsViewModel)
                                .navigationDestination(for: AppRoute.self) { route in
                                    router.destination(for: route)
                                }
                        }
                        
                    case .aiPhoto:
                        NavigationStack(path: $router.aiPhotoPath) {
                            AiPhotoView(viewModel: aiPhotoViewModel)
                                .navigationDestination(for: AppRoute.self) { route in
                                    router.destination(for: route)
                                }
                                .task {
                                    withAnimation(.easeInOut) { router.isTabBarHidden = true }
                                }
                        }
                        
                    case .history:
                        NavigationStack(path: $router.historyPath) {
                            HistoryView(
                                viewModel: historyViewModel
                            )
                            .navigationDestination(for: AppRoute.self) { route in
                                router.destination(for: route)
                            }
                        }
                        
                    case .settings:
                        NavigationStack(path: $router.settingsPath) {
                            SettingsView(viewModel: settingsViewModel)
                                .navigationDestination(for: AppRoute.self) { route in
                                    router.destination(for: route)
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                // MARK: - Tab Bar поверх
                if !router.isTabBarHidden {
                    CustomTabBar(router: router)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(1)
                }
            } else {
                OnboardingView {
                    onboardingCompleted = true
                    withAnimation(.easeInOut) {
                        showOnboarding = false
//                        router.isTabBarHidden = false
//                        router.selectedTab = .effects
                    }
                }
            }
        }
        .onAppear {
            observeNotificationTap()
        }
    }
    
    private func observeNotificationTap() {
        NotificationCenter.default.publisher(for: .openGenerationFromNotification)
            .sink { notification in
                guard let gen = notification.userInfo?["generationId"] as? String else {
                    print("⚠️ Notification: no GenerationResponse found")
                    return
                }

                Task { @MainActor in
                    router.selectedTab = .history
                    router.push(.result(gen))
                }
            }
            .store(in: &cancellables)
    }
}
