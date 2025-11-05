//
//  HistoryViewModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 11.10.2025.
//

import SwiftUI
import Combine
import Alamofire

@MainActor
final class HistoryViewModel: ObservableObject {
    
    @Published var history: [GenerationResponse] = []
    @Published var isLoading = false
    @Published var hasMore = true
    @Published var tokensCount: Int = 0

    private let networkService = NetworkService()
    private var currentOffset = 0
    private let pageSize = 30
    private var cancellables = Set<AnyCancellable>()

    private var router: Router
    
    init(router: Router) {
        self.router = router
        Task.detached(priority: .background) {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            await self.loadHistory(reset: true)
        }
        
        NotificationCenter.default.publisher(for: .didFinishGenerate)
            .sink { [weak self] _ in
                Task {
                    await self?.loadHistory(reset: true)
                }
                
                Task {
                    await self?.fetchUserInfo()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadHistory(reset: Bool = false) async {
        guard !isLoading, hasMore || reset else { return }
        isLoading = true
        defer { isLoading = false }

        if reset {
            currentOffset = 0
            hasMore = true
            history.removeAll()
        }

        guard let token = UserSessionManager.shared.accessToken else {
            print("❌ No access token found")
            return
        }

        var components = URLComponents(string: "https://aiphotoappfull.webberapp.shop/api/generations/user/me")!
        components.queryItems = [
            .init(name: "count", value: "\(pageSize)"),
            .init(name: "offset", value: "\(currentOffset)"),
            .init(name: "type", value: "fotobudka_photo_godmode")
        ]

        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]

        do {
            let response: HistoryResponse = try await networkService.get(url: components.url!, headers: headers)
            history.append(contentsOf: response.items)
            currentOffset += response.items.count
            if response.items.count < pageSize { hasMore = false }
        } catch {
            print("❌ History fetch error:", error)
        }
    }
    
    @MainActor
    func effectTap(on item: GenerationResponse) {
        router.push(.result(item.result))
    }
    
    @MainActor
    func effectsTap() {
        router.selectedTab = .samples
    }
    
    @MainActor
    func fetchUserInfo() async {
        let network = NetworkService()
        guard let token = UserSessionManager.shared.accessToken else {
            print("❌ Нет accessToken")
            return
        }
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        guard let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/users/me") else {
            print("❌ Некорректный URL")
            return
        }
        
        do {
            let response: UserResponse = try await network.get(url: url, headers: headers)
            self.tokensCount = response.tokens ?? 0
        } catch {
            print("❌ Ошибка получения токенов:", error.localizedDescription)
        }
    }
}
