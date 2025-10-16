//
//  CreateAvatarViewModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 07.10.2025.
//

import Foundation
import SwiftUI
import Alamofire

enum AvatarStep {
    case intro
    case genderSelect
    case nameInput
    case photoUpload
    case generating
    case showResult
    case showErrors
}

enum Gender: String, CaseIterable {
    case woman = "Woman"
    case man = "Man"
}

@MainActor
final class CreateAvatarViewModel: ObservableObject {
    @Published var step: AvatarStep = .intro
    @Published var introPageIndex: Int = 0
    @Published var gender: Gender? = .woman
    @Published var showAlert: AlertType = .none
    @Published var showAvatarPaywall = false

    @Published var avatarName: String = ""
    @Published var photos: [UIImage] = []
    @Published var isGenerating: Bool = false
    @Published var result: UserAvatar?
    @Published var avatarTokens: Int = 0
    
    let router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    deinit {
        print("Случился DEINIT")
    }
    
    func next() {
        switch step {
        case .intro:
            if introPageIndex < 3 {
                introPageIndex += 1
            } else {
                step = .genderSelect
            }
        case .genderSelect:
            step = .nameInput
        case .nameInput:
            step = .photoUpload
        case .photoUpload:
            Task {
                await generateAvatar()
            }
        case .generating:
            step = .showResult
        case .showResult:
            step = .showErrors
        case .showErrors:
            break
        }
    }
    
    func back() {
        if step == .intro && introPageIndex > 0 {
            introPageIndex -= 1
        } else if step != .intro {
            switch step {
            case .intro:
                break
            case .genderSelect:
                router.pop()
            case .nameInput:
                step = .genderSelect
            case .photoUpload:
                step = .nameInput
            case .generating:
                router.pop()
            case .showResult:
                router.pop()
                step = .intro
            case .showErrors:
                step = .photoUpload
            }
        } else {
            router.pop()
        }
    }
    
    func skip() {
        if step == .intro {
            step = .genderSelect
        }
    }
    
    func generateAvatar() async {
        
        let canWeStart = await checkTokens()
        
        guard canWeStart else {
            showAvatarPaywall = true
            return
        }
        
        let network = NetworkService()
        var gender: String {
            switch self.gender {
            case .woman:
                "f"
            case .man:
                "m"
            case .none:
                "m"
            }
        }
        let title = self.avatarName.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let photoURLs = try photos.saveAllToTemporaryDirectory()
            guard let previewURL = photoURLs.first else { return }

            await MainActor.run {
                step = .generating
            }
            
            // 1️⃣ Создаём аватар (инициируем генерацию)
            let response = try await uploadAvatar(photoURLs: photoURLs, previewURL: previewURL)
            print("✅ Generation started:", response)
           
            // 2️⃣ Ждём пока статус станет "finished"
            let final = try await waitForGenerationToFinish(id: response.id)
            
            print("✅ Generation finished:", final.id)

            // 3️⃣ Получаем список всех аватаров
            let avatars = try await fetchUserAvatars()
            print("📦 Total avatars:", avatars.count)

            // 4️⃣ Находим нужный по id
            if let matched = avatars.first(where: { String($0.id) == final.result }) {
                await MainActor.run {
                    self.result = matched
                    self.step = .showResult
                    self.isGenerating = false
                }
            } else {
                print("⚠️ Avatar not found in list for id \(final.id)")
                await MainActor.run {
                    self.step = .showErrors
                    self.isGenerating = false
                }
            }
        } catch {
            await MainActor.run {
                step = .photoUpload
                showAlert = .error
            }
        }
        
        func uploadAvatar(photoURLs: [URL], previewURL: URL) async throws -> GenerationResponse {
            let query = "https://aiphotoappfull.webberapp.shop/api/generations/fotobudka/avatar?gender=\(gender)&title=\(title)"
            guard let url = URL(string: query) else { throw URLError(.badURL) }
            
            var headers: HTTPHeaders = [
                "accept": "application/json"
            ]
            if let token = UserSessionManager.shared.accessToken {
                headers.add(name: "Authorization", value: "Bearer \(token)")
            }
            
            return try await network.post(url: url, headers: headers) { formData in
                for photo in photoURLs {
                    formData.append(photo, withName: "photos", fileName: photo.lastPathComponent, mimeType: "image/jpeg")
                }
                formData.append(previewURL, withName: "preview", fileName: previewURL.lastPathComponent, mimeType: "image/jpeg")
            }
        }
    }
    
    private func waitForGenerationToFinish(id: String) async throws -> GenerationResponse {
        let network = NetworkService()
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(UserSessionManager.shared.accessToken ?? "")"
        ]

        var attempt = 0
        while attempt < 240 {
            let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/\(id)")!
            let response: GenerationResponse = try await network.get(url: url, headers: headers)
            print("🌀 [\(attempt)] Status: \(response.status)")

            switch response.status {
            case "finished":
                NotificationCenter.default.post(name: .didFinishAvatarCreate, object: nil)
                await fetchUserInfo()
                return response
            case "error":
                throw NSError(domain: "AvatarGeneration", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: response.error ?? "Ошибка генерации"
                ])
            case "queued", "started":
                try await Task.sleep(for: .seconds(2))
                attempt += 1
            default:
                throw NSError(domain: "AvatarGeneration", code: -2, userInfo: [
                    NSLocalizedDescriptionKey: "Неизвестный статус: \(response.status)"
                ])
            }
        }

        throw NSError(domain: "AvatarGeneration", code: -3, userInfo: [
            NSLocalizedDescriptionKey: "Таймаут ожидания генерации"
        ])
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
    
    func checkTokens() async -> Bool{
        await fetchUserInfo()
        if avatarTokens <= 0 {
            return false
        } else {
            return true
        }
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
            self.avatarTokens = response.avatar_tokens ?? 0
            print("💰 Avatar tokens count (UI thread):", self.avatarTokens)
        } catch {
            print("❌ Ошибка получения токенов:", error.localizedDescription)
        }
    }
}
