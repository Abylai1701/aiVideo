//
//  AiPhotoViewModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 09.10.2025.
//

import Foundation
import UIKit
import Combine
import Alamofire
import Kingfisher

enum AiPhotoSteps {
    case opened, generate, result
}

final class AiPhotoViewModel: ObservableObject {
    let router: Router
    private var cancellables = Set<AnyCancellable>()
    @Published var result: GenerationResponse?
    @Published var tokensCount: Int = 0
    @Published var showTokensPaywall = false

    init(router: Router) {
        self.router = router
        self.step = .opened
        
        Task(priority: .userInitiated) {
            let responce = try await fetchUserAvatars()
            await MainActor.run {
                avatars = responce
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
                }
            }
            .store(in: &cancellables)
    }
    
    @Published var step: AiPhotoSteps
    @Published var prompt: String = ""
    @Published var aspectRatio: AspectRatioType = .three_two
    @Published var showAlert: AlertType = .none
    @Published var avatars: [UserAvatar] = []

    private func fetchUserAvatars() async throws -> [UserAvatar] {
        let network = NetworkService()
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(UserSessionManager.shared.accessToken ?? "")"
        ]

        let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/fotobudka/avatar")!
        return try await network.get(url: url, headers: headers)
    }
    
    @MainActor
    func popToRoot() {
        prompt = ""
        step = .opened
        router.popToRoot()
    }
    @MainActor
    func pop() {
        router.pop()
    }
    
    @MainActor
    func pushToCreateAvatar() {
        router.push(.createAvatar)
    }
    
    func download() async {
        guard let result = result else {
            return
        }
        guard let urlString = result.result, let url = URL(string: urlString) else {
            print("❌ Invalid image URL")
            return
        }
        
        do {
            let image = try await KingfisherManager.shared.retrieveImage(with: url).image
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print("✅ Image saved to Photos")
            await MainActor.run { showAlert = .save }
            
        } catch {
            print("❌ Failed to download image:", error.localizedDescription)
            await MainActor.run { showAlert = .failed }
        }
    }
    
    func downloadImage() async -> UIImage? {
        
        guard let result = result else {
            return nil
        }
        
        guard let urlString = result.result,
              let url = URL(string: urlString) else { return nil }
        do {
            let image = try await KingfisherManager.shared.retrieveImage(with: url).image
            return image
        } catch {
            print("❌ Failed to get image for share:", error.localizedDescription)
            return nil
        }
    }
    @MainActor
    func delete() {
        showAlert = .delete
    }
}

extension AiPhotoViewModel {
    func generatePhoto(avatar: UserAvatar) async {

        let canWeStart = await checkTokens()
        
        guard canWeStart else {
            showTokensPaywall = true
            return
        }
        
        await MainActor.run {
            self.step = .generate
        }

        let network = NetworkService()
        let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/fotobudka/photo-godmode")!
        
        let body = PhotoGodmodeRequest(
            type: "fotobudka_photo_godmode",
            prompt: prompt ,
            avatar_id: avatar.id,
            aspect_ratio: aspectRatio.value,
            template_id: nil,
            is_free_god_mode: false
        )
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(UserSessionManager.shared.accessToken ?? "")"
        ]
        
        do {
            let response: GenerationResponse = try await network.postJSON(url: url, headers: headers, body: body)
            print("✅ Photo generation started:", response)
            
            try await pollGenerationStatus(id: response.id)
        } catch {
            print("❌ Failed to generate photo:", error.localizedDescription)
            await MainActor.run {
                self.showAlert = .error
                self.step = .opened
            }
        }
    }

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
            await MainActor.run {
                if let tokens = response.tokens {
                    self.tokensCount = tokens
                }
                print("💰 Tokens count:", response.tokens as Any)
            }
        } catch {
            print("❌ Ошибка получения токенов:", error.localizedDescription)
        }
    }

    func checkTokens() async -> Bool{
        await fetchUserInfo()
        if tokensCount <= 0 {
            return false
        } else {
            return true
        }
    }
    
    private func pollGenerationStatus(id: String) async throws {
        let network = NetworkService()
        let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/\(id)")!
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(UserSessionManager.shared.accessToken ?? "")"
        ]
        
        var attempt = 0
                
        while attempt < 500 {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            let status: GenerationResponse = try await network.get(url: url, headers: headers)
            print("🔄 Status:", status.status)
            
            if attempt < 2 {
                NotificationCenter.default.post(name: .didFinishGenerate, object: nil)
            }
            if status.status == "finished" {
                NotificationCenter.default.post(name: .didFinishGenerate, object: nil)
                await MainActor.run {
                    self.result = status
                    self.step = .result
                }
                print("✅ Generation finished:", status.result ?? "")
                
                if let resultURLString = status.result {
                    NotificationService.shared.scheduleGenerationFinished(id: resultURLString,
                                                                          body: "Tap to open your result.")
                }
                
                return
            }
            if status.status == "error" {
                await MainActor.run {
                    self.showAlert = .error
                    self.step = .opened
                }
                return
            }
            
            attempt += 1
        }
        
        throw URLError(.timedOut)
    }
}
