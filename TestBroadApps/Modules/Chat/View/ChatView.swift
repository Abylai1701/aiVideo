//
//  ChatView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 03.11.2025.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    @StateObject private var keyboard = KeyboardObserver()
    @State private var inputText = ""
    var showSidebar: () -> Void
    
    @State private var showSheet: Bool = false
    @State var showAspectRatioSheet: Bool = false
    @State private var showCamera: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                TopBar(
                    title: viewModel.selectedChat?.title ?? "Temporary chat",
                    badge: "\(viewModel.imageTokens)",
                    onMenu: {
                        showSidebar()
                    },
                    onFilters: {
                        showAspectRatioSheet = true
                    }
                )
                Rectangle()
                    .fill(.grayF5F5F5)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                chat
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
            .ignoresSafeArea(edges: .bottom)
            .overlay(alignment: .bottom) {
                ChatInputBar(
                    text: $inputText,
                    selectedImages: $viewModel.selectedImages,
                    onSend: {
                        let text = inputText
                        inputText = ""
                        Task {
                            await viewModel.sendMessage(text)
                        }
                    },
                    selectType: { showSheet = true }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, keyboard.height > 0 ? 16 : 80)
                .animation(.easeOut(duration: 0.25), value: keyboard.height)
            }
            
            if showSheet || showAspectRatioSheet {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            if viewModel.selectedChat == nil {
                viewModel.selectedChat = viewModel.store.chats.first
            }
            Task {
                await viewModel.fetchUserInfo()
            }
        }
        .hideKeyboardOnTap()
        .sheet(isPresented: $showAspectRatioSheet) {
            AspectRatioSheetView(
                selectedAspect: $viewModel.aspectRatio
            )
            .presentationDetents([.height(200)])
            .presentationCornerRadius(40)
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showSheet) {
            SelectTypeOfAddingSheet(gallerySelect: {
                viewModel.showPhotoPicker = true
            }, cameraSelect: {
                showCamera = true
            })
            .presentationDetents([.height(180)])
            .presentationCornerRadius(40)
            .presentationDragIndicator(.hidden)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                viewModel.handleCameraImage(image)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $viewModel.showTokenPaywall) {
            Task {
                await viewModel.fetchUserInfo()
            }
        } content: {
            TokenPaywall() {
                Task {
                    await viewModel.fetchUserInfo()
                }
            }
            .presentationDetents([.height(510)])
            .presentationCornerRadius(32)
            .presentationDragIndicator(.hidden)
        }
        .fullScreenCover(isPresented: $viewModel.showPaywall) {
            PaywallView()
        }
        .photosPicker(
            isPresented: $viewModel.showPhotoPicker,
            selection: $viewModel.selectedPhotoItem,
            matching: .images
        )
        .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
            Task { await viewModel.handlePhotoPickerChange(newItem) }
        }
    }
    
    private var chat: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 14) {
                   messages
                    // нижний якорь
                    Color.clear
                        .frame(height: keyboard.height > 0 ? keyboard.height + 100 : 170)
                        .id(bottomID)
                }
                .padding(.vertical, 12)
                
                // ✅ при первом появлении — сразу в конец БЕЗ анимации
                .onAppear {
                    scrollToBottom(proxy, animated: false)
                }
                
                // ✅ при смене выбранного чата — сразу в конец БЕЗ анимации
                .onChange(of: viewModel.selectedChat?.id) { _, _ in
                    scrollToBottom(proxy, animated: false)
                }
                
                // ✅ при добавлении нового сообщения — плавно к низу
                .onChange(of: viewModel.currentMessages.count) { _, _ in
                    scrollToBottom(proxy, animated: true)
                }
                
                // ✅ при появлении клавиатуры — плавно к низу
                .onChange(of: keyboard.height) { _, _ in
                    scrollToBottom(proxy, animated: true)
                }
            }
        }
    }
    
    private var messages: some View {
        ForEach(viewModel.currentMessages) { msg in
            MessageRow(message: msg)
                .id(msg.id)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let data = msg.imageData {
                        if let path = saveImageToTemp(data: data) {
                            viewModel.router.push(.result(path))
                        }
                    }
                }
        }
        
    }
    
    private let bottomID = "BOTTOM_ID"
    
    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool) {
        if animated {
            withAnimation { proxy.scrollTo(bottomID, anchor: .bottom) }
        } else {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) {
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
        }
    }

    private func saveImageToTemp(data: Data) -> String? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
        do {
            try data.write(to: url)
            return url.path
        } catch {
            print("⚠️ Failed to write temp image:", error.localizedDescription)
            return nil
        }
    }

}
