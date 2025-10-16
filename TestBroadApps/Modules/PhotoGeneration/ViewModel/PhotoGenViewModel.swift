//
//  PhotoGenViewModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

enum AlertType {
    case save
    case failed
    case error
    case delete
    case none
}

import Foundation
import UIKit
import Alamofire
import Combine
import Kingfisher

final class PhotoGenViewModel: ObservableObject {
    
    enum PhotoGenSteps {
        case opened, generate, result
    }
        
    @Published var photo: String?
    private var prompt: String?
    private var templateId: Int?
    
    @Published var step: PhotoGenSteps
    @Published var showAlert: AlertType = .none
    @Published var result: GenerationResponse?
    @Published var tokensCount: Int = 0
    @Published var showTokenPaywall = false

    @Published var avatars: [UserAvatar] = []

    private var cancellables = Set<AnyCancellable>()

    private var router: Router

    init(router: Router, photo: String?, prompt: String?, templateId: Int?) {
        self.router = router
        self.photo = photo
        self.step = .opened
        self.prompt = prompt
        self.templateId = templateId
        
        print("prompt: \(String(describing: prompt))")
        print("templateId: \(String(describing: templateId))")
        
        Task(priority: .userInitiated) {
            await self.fetchUserInfo()

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
    
    func takeInfo() {
        
    }
    @MainActor
    func pop() {
        router.pop()
    }
    
    @MainActor
    func popToRoot() {
        router.popToRoot()
    }
    
    @MainActor
    func pushToCreateAvatar() {
        router.push(.createAvatar)
    }
    
    private func fetchUserAvatars() async throws -> [UserAvatar] {
        let network = NetworkService()
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(UserSessionManager.shared.accessToken ?? "")"
        ]

        let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/fotobudka/avatar")!
        return try await network.get(url: url, headers: headers)
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
            showAlert = .save
            
        } catch {
            print("❌ Failed to download image:", error.localizedDescription)
            showAlert = .failed
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
        if tokensCount <= 0 { // FIX
            return false
        } else {
            return true
        }
    }
}

extension PhotoGenViewModel {
    func generatePhoto(avatar: UserAvatar) async {
        
        let canWeStart = await checkTokens()
        
        guard canWeStart else {
            await MainActor.run {
                showTokenPaywall = true
            }
            return
        }
        
        guard let templateId = templateId else {
            print("❌ Missing data for generation")
            return
        }

        await MainActor.run {
            self.step = .generate
        }

        let network = NetworkService()
        let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/fotobudka/photo-godmode")!
        
        let body = PhotoGodmodeRequest(
            type: "fotobudka_photo_godmode",
            prompt: prompt ?? "Сделай красивое фото с этим аватором",
            avatar_id: avatar.id,
            aspect_ratio: nil,
            template_id: templateId,
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
                await fetchUserInfo()
                print("✅ Generation finished:", status.result ?? "")
                
                await fetchUserInfo()
                
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
