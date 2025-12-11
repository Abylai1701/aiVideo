//
//  ChatViewModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.11.2025.
//

import SwiftUI
import PhotosUI
import Alamofire
import Kingfisher
import Combine
import ApphudSDK

final class ChatViewModel: ObservableObject {
    
    private let network: NetworkService
    let router: Router
    
    @MainActor @Published var store = ChatStore()
    @MainActor @Published var selectedChat: Chat?
    @MainActor @Published var selectedImages: [ChatImage] = []
    @MainActor @Published var aspectRatio: AspectRatioType = .three_two
    @MainActor @Published var isLoading = false
    
    @MainActor @Published var showPhotoPicker = false
    @MainActor @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var imageTokens: Int = 0

    private var cancellables = Set<AnyCancellable>()

    @MainActor @Published var currentMessages: [Message] = []
    @Published var showTokenPaywall = false
    @Published var showPaywall = false

    @MainActor
    init(router: Router, network: NetworkService = NetworkService()) {
        self.router = router
        self.network = network
        print("Создается новый view")
        Task {
            await self.fetchUserInfo()
        }
        store.$chats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chats in
                guard let self else { return }

                if let selectedId = self.selectedChat?.id {
                    self.selectedChat = chats.first(where: { $0.id == selectedId })
                }

                self.refreshCurrentMessages()
            }
            .store(in: &cancellables)


         $selectedChat
             .receive(on: DispatchQueue.main)
             .sink { [weak self] _ in
                 self?.refreshCurrentMessages()
             }
             .store(in: &cancellables)
    }
    
    @MainActor
    private func refreshCurrentMessages() {
        let messages = store.chats.first(where: { $0.id == selectedChat?.id })?.messages ?? []
        currentMessages = messages
    }
    
    func handleCameraImage(_ image: UIImage) {
        Task.detached { [weak self] in
            guard let self else { return }
            if let data = image.jpegData(compressionQuality: 0.8),
               let uiImage = UIImage(data: data) {
                let chatImage = ChatImage(image: uiImage)
                await MainActor.run { self.selectedImages = [chatImage] }
            }
        }
    }

    func sendMessage(_ text: String) {
        if Apphud.hasPremiumAccess() {
            let canWeStart = checkTokens()
            
            guard canWeStart else {
                showTokenPaywall = true
                return
            }
            
            Task { @MainActor in
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty || !self.selectedImages.isEmpty else { return }
                
                let chat = self.ensureChat()
                
                // 1) Добавляем сообщения в UI
                self.store.addMessage(Message(text: trimmed, isUser: true), to: chat)
                
                var imageData: Data?
                if let uiImage = self.selectedImages.first?.image {
                    imageData = uiImage.jpegData(compressionQuality: 0.8)
                    self.store.addMessage(Message(text: "", isUser: true, imageData: imageData), to: chat)
                }
                
                self.selectedImages.removeAll()
                self.selectedChat = chat
                self.isLoading = true
                self.refreshCurrentMessages()
                
                Task.detached { [weak self] in
                    guard let self else { return }
                    do {
                        let aspect = await self.aspectRatio.value
                        let response = try await self.uploadPrompt(
                            lastMessages: chat.messages,
                            text: trimmed,
                            imageData: imageData,
                            aspectRatio: aspect
                        )
                        await fetchUserInfo()
                        try await self.pollGenerationStatus(id: response.id, chat: chat)
                    } catch {
                        await MainActor.run {
                            self.store.addMessage(
                                Message(text: "❌ Error: \(error.localizedDescription)", isUser: false),
                                to: chat
                            )
                            self.isLoading = false
                        }
                    }
                }
            }
        } else {
            showPaywall = true
        }
    }



    private func uploadPrompt(
        lastMessages: [Message],
        text: String,
        imageData: Data?,
        aspectRatio: String
    ) async throws -> GenerationResponse {
        guard let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/fotobudka/nanobanana") else {
            throw URLError(.badURL)
        }

        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(UserSessionManager.shared.accessToken ?? "")"
        ]

        // 🧩 Если последнее сообщение — это пользовательский текст, уберём только его
        var timeline = lastMessages
        if let last = lastMessages.last, last.isUser {
            timeline.removeLast()
        }

        // 🧠 Находим последнюю фотку ассистента (включая самые свежие с бэка)
        var pickedAssistantImage: Data? = nil
        var pickedIndex: Int? = nil
        if let idx = timeline.lastIndex(where: { !$0.isUser && ($0.imageData?.isEmpty == false) }) {
            pickedAssistantImage = timeline[idx].imageData
            pickedIndex = idx
            print("🧩 Using assistant image from index: \(idx) of \(timeline.count - 1)")
        } else {
            print("🧩 No assistant image found in chat history.")
        }

        // 🧠 Формируем prompt и прикладываемое изображение
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let (prompt, attachedImageData): (String, Data?) = {
            if let userImage = imageData {
                // Пользователь отправил фото
                let p = "Юзер:\n" + (trimmed.isEmpty ? "(без текста)" : trimmed)
                print("➡️ Attach: USER image (\(userImage.count) bytes)")
                return (p, userImage)
            } else if let seed = pickedAssistantImage {
                // Пользователь отправил только текст — редактируем последнюю фотку ассистента
                let p = "Ассистент:\nЕго ответ (фото)\nЮзер:\n" + (trimmed.isEmpty ? "(без текста)" : trimmed)
                print("👉 PICKED assistant image index: \(pickedIndex ?? -1) / \(timeline.count - 1)")
                print("➡️ Attach: ASSISTANT last image (\(seed.count) bytes)")
                return (p, seed)
            } else {
                // В истории нет фото
                let p = "Юзер:\n" + (trimmed.isEmpty ? "(без текста)" : trimmed)
                print("➡️ Attach: NO IMAGE (no assistant images in history)")
                return (p, nil)
            }
        }()

        // 🔍 Для отладки: выводим последние сообщения
        let tail = max(0, timeline.count - 10)
        print("——— TAIL (\(timeline.count - tail)) ———")
        for (i, m) in timeline[tail...].enumerated() {
            let realIdx = tail + i
            let who = m.isUser ? "USER" : "ASSISTANT"
            let hasImg = (m.imageData?.isEmpty == false) ? "IMG✅" : "IMG—"
            let t = m.text.isEmpty ? "(no text)" : m.text.prefix(18) + (m.text.count > 18 ? "…" : "")
            print("[\(realIdx)] \(who)  \(hasImg)  text: \(t)")
        }

        // 📡 Отправляем запрос
        return try await network.post(url: url, headers: headers) { formData in
            formData.append("fotobudka_nanobanana".data(using: .utf8)!, withName: "type")
            formData.append(prompt.data(using: .utf8)!, withName: "prompt")
            formData.append(aspectRatio.data(using: .utf8)!, withName: "aspect_ratio")

            if let data = attachedImageData {
                formData.append(
                    data,
                    withName: "images",
                    fileName: "upload.jpg",
                    mimeType: "image/jpeg"
                )
            }
        }
    }


    // MARK: - Polling status
    private func pollGenerationStatus(id: String, chat: Chat) async throws {
        guard let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/generations/\(id)") else { return }

        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(UserSessionManager.shared.accessToken ?? "")"
        ]

        var attempt = 0
        let maxAttempts = 500

        while attempt < maxAttempts {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            let status: GenerationResponse = try await network.get(url: url, headers: headers)
            print("🔄 Status:", status.status)

            if status.status == "finished" {
                await MainActor.run { self.isLoading = false }

                // ✅ Изображение грузим в фоне
                if let urlString = status.result,
                   let resultURL = URL(string: urlString) {

                    Task.detached { [weak self] in
                        guard let self else { return }
                        do {
                            let result = try await KingfisherManager.shared.retrieveImage(with: resultURL).image
                            let data = result.pngData()
                            await MainActor.run {
                                self.store.addMessage(
                                    Message(text: "", isUser: false, imageData: data),
                                    to: chat
                                )
                                self.selectedChat = chat
                            }
                        } catch {
                            await MainActor.run {
                                self.store.addMessage(
                                    Message(text: "✅ Generated! But failed to download image.", isUser: false),
                                    to: chat
                                )
                                self.selectedChat = chat
                            }
                        }
                    }
                } else {
                    await MainActor.run {
                        self.store.addMessage(Message(text: "✅ Generation finished (no image)", isUser: false), to: chat)
                        self.selectedChat = chat
                    }
                }
                return
            }

            if status.status == "error" {
                await MainActor.run {
                    self.isLoading = false
                    self.store.addMessage(Message(text: "❌ Generation failed", isUser: false), to: chat)
                }
                return
            }

            attempt += 1
        }

        await MainActor.run {
            self.isLoading = false
            self.store.addMessage(Message(text: "⏱ Timeout waiting for generation", isUser: false), to: chat)
        }
    }
    
    func handlePhotoPickerChange(_ item: PhotosPickerItem?) async {
        guard let item else { return }

        Task.detached { [weak self] in
            guard let self else { return }
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.selectedImages = [ChatImage(image: uiImage)]
                }
            }
        }
    }


    // MARK: - Chat management
    @MainActor
    private func ensureChat() -> Chat {
        if let chat = selectedChat { return chat }
        let new = Chat(title: "Temporary chat")
        store.chats.append(new)
        selectedChat = new
        return new
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
            self.imageTokens = response.tokens ?? 0
        } catch {
            print("❌ Ошибка получения токенов:", error.localizedDescription)
        }
    }
    
    func checkTokens() -> Bool {
        Task {
            await fetchUserInfo()
        }
        
        if imageTokens <= 0 {
            return false
        } else {
            return true
        }
    }
}
