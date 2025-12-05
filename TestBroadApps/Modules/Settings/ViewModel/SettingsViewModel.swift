//
//  SettingsViewModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//

import Foundation
import Alamofire
import UIKit
import Kingfisher
import Combine

final class SettingsViewModel: ObservableObject {
    
    private var router: Router
    @Published var avatars: [UserAvatar] = []
    private var cancellables = Set<AnyCancellable>()

    @Published var imageTokens: Int = 0
    @Published var avatarTokens: Int = 0

    init(router: Router) {
        self.router = router
        
        Task.detached(priority: .background) {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            let responce = try await self.fetchUserAvatars()
            await MainActor.run {
                self.avatars = responce
            }
        }
        
        NotificationCenter.default.publisher(for: .didFinishAvatarCreate)
            .sink { [weak self] _ in
                Task {
                    if let avatarss = try await self?.fetchUserAvatars() {
                        await MainActor.run {
                            self?.avatars = avatarss
                        }
                    }
                    Task {
                        await self?.fetchUserInfo()
                    }
                }
            }
        
        NotificationCenter.default.publisher(for: .didFinishGenerate)
            .sink { [weak self] _ in
                Task {
                    await self?.fetchUserInfo()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func fetchAvatars() {
        Task.detached(priority: .background) {
            let responce = try await self.fetchUserAvatars()
            await MainActor.run {
                self.avatars = responce
            }
        }
    }
    @MainActor
    func pushToCreateAvatar() {
        router.push(.createAvatar)
    }
    
    @MainActor
    func pushToRate() {
        router.push(.rateApp)
    }
    
    func fetchUserAvatars() async throws -> [UserAvatar] {
        let network = NetworkService()
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(UserSessionManager.shared.accessToken ?? "")"
        ]

        let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/fotobudka/avatar")!
        return try await network.get(url: url, headers: headers)
    }
}

extension SettingsViewModel {
    func updateAvatarTitle(avatar: UserAvatar, newName: String) async {
        let network = NetworkService()
        let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/fotobudka/avatar")!
        
        let body = UpdateAvatarRequest(
            gender: avatar.gender ?? "f",
            title: newName,
            avatarId: "\(avatar.id)",
            isActive: true
        )
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(UserSessionManager.shared.accessToken ?? "")",
            "Content-Type": "application/json"
        ]
        
        do {
            let updated: UserAvatar = try await network.patch(url: url, body: body, headers: headers)
            await MainActor.run {
                if let index = avatars.firstIndex(where: { $0.id == updated.id }) {
                    avatars[index] = updated
                }
            }
            print("✅ Updated avatar title:", updated.title as Any)
        } catch {
            print("❌ Failed to update avatar title:", error.localizedDescription)
        }
    }
}

extension SettingsViewModel {
    func updateAvatarPreview(avatarId: Int, image: UIImage) async {
        let network = NetworkService()
        
        guard let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/fotobudka/avatar/\(avatarId)/preview") else {
            print("❌ Invalid URL")
            return
        }

        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(UserSessionManager.shared.accessToken ?? "")"
        ]

        do {
            guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                print("❌ Could not convert image to data")
                return
            }
            
            let response: [UserAvatar] = try await network.post(url: url, headers: headers) { formData in
                formData.append(
                    imageData,
                    withName: "preview",
                    fileName: "avatar_preview.jpg",
                    mimeType: "image/jpeg"
                )
            }
            
            print("✅ Updated avatar preview")
            
            if let _ = response.first {
                Task {
                    let avatars = try await fetchUserAvatars()
                    await MainActor.run {
                        self.avatars = avatars
                    }
                }
            }
        } catch {
            print("❌ Failed to update avatar preview:", error.localizedDescription)
        }
    }
}

extension SettingsViewModel {
    
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
            self.avatarTokens = response.avatar_tokens ?? 0
            self.imageTokens = response.tokens ?? 0
        } catch {
            print("❌ Ошибка получения токенов:", error.localizedDescription)
        }
    }
    
    func deleteAvatar(avatarId: Int) async {
        let network = NetworkService()
        guard let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/fotobudka/avatar/\(avatarId)") else {
            print("❌ Invalid URL")
            return
        }

        let headers: HTTPHeaders = [
            "accept": "*/*",
            "Authorization": "Bearer \(UserSessionManager.shared.accessToken ?? "")"
        ]

        do {
            try await network.delete(url: url, headers: headers)
            print("✅ Avatar deleted:", avatarId)
            
            let updated = try await fetchUserAvatars()
            await MainActor.run {
                self.avatars = updated
            }
        } catch {
            print("❌ Failed to delete avatar:", error.localizedDescription)
        }
    }
}
