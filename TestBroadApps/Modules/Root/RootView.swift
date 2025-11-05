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
    @StateObject private var chatViewModel: ChatViewModel
    
    @AppStorage("onboardingСompleted") private var onboardingCompleted = false
    @State private var showOnboarding = false
    @State private var isSidebarOpen = false

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
        _chatViewModel = StateObject(
            wrappedValue: ChatViewModel(router: router)
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if onboardingCompleted {
                Group {
                    switch router.selectedTab {
                    case .samples:
                        NavigationStack(path: $router.effectsPath) {
                            EffectsView(viewModel: effectsViewModel)
                                .navigationDestination(for: AppRoute.self) { route in
                                    router.destination(for: route)
                                }
                        }
                        
                    case .chat:
                        NavigationStack(path: $router.aiPhotoPath) {
                            ChatView(viewModel: chatViewModel) {
                                router.present(.chatSidebar)
                                isSidebarOpen = true
                                
                            }
                            .navigationDestination(for: AppRoute.self) { route in
                                router.destination(for: route)
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
                
                Color.black
                    .opacity(isSidebarOpen ? 0.6 : 0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.25), value: isSidebarOpen)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            router.dismissOverlay()
                            isSidebarOpen = false
                        }
                    }
                    .zIndex(3)

                Group {
                    switch router.overlay {
                    case .none:
                        EmptyView()
                        
                    case .chatSidebar:
                        ChatSidebarOverlay(viewModel: chatViewModel) {
                            isSidebarOpen = false
                        }
                    }
                }
                .zIndex(9999)
                .transition(.move(edge: .leading))
                
            } else {
                OnboardingView {
                    onboardingCompleted = true
                    withAnimation(.easeInOut) {
                        showOnboarding = false
                    }
                }
            }
        }
        .onAppear {
            observeNotificationTap()
        }
        .environmentObject(router)
        .ignoresSafeArea(.keyboard)
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
