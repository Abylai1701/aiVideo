//
//  SidebarView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 03.11.2025.
//

import SwiftUI

struct ChatSidebarOverlay: View {
    @EnvironmentObject private var router: Router
    @ObservedObject var viewModel: ChatViewModel

    private let sidebarWidthRatio: CGFloat = 0.7
    var close: () -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.clear
            SidebarView(
                viewModel: viewModel,
                close: {
                    router.dismissOverlay()
                    close()
                }
            )
            .frame(width: UIScreen.main.bounds.width * sidebarWidthRatio)
            .offset(x: router.overlay == .chatSidebar ? 0 : -UIScreen.main.bounds.width * sidebarWidthRatio)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: router.overlay)
        }
    }
}


import SwiftUI
import ApphudSDK

struct SidebarView: View {
    @ObservedObject var viewModel: ChatViewModel
    var close: () -> Void
    @State private var showPaywall = false

    // MARK: - Local UI state
    @State private var chatToRename: Chat?
    @State private var newTitle: String = ""
    @State private var chatToDelete: Chat?
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            // top bar
            HStack {
                Button { close() } label: {
                    Image(.closeIcon)
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 32)

            Button {
                let newChat = viewModel.store.createChat(title: "New chat")
                viewModel.selectedChat = newChat
                close()
            } label: {
                HStack(spacing: 8) {
                    Image(.newChatIcon)
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("New chat")
                        .font(.interMedium(size: 16))
                        .foregroundStyle(.black101010)
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 40)

            Text("Chats")
                .font(.interMedium(size: 15))
                .foregroundStyle(.black101010.opacity(0.7))
                .padding(.leading)
                .padding(.bottom)

            // 🔽 вот тут меняем VStack на ScrollView + LazyVStack
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.store.chats) { chat in
                        HStack(spacing: 10) {
                            Text(chat.title)
                                .lineLimit(1)
                                .font(.interMedium(size: 16))
                                .foregroundStyle(.black101010)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.selectedChat = chat
                                    close()
                                }

                            Spacer()

                            Menu {
                                Button {
                                    chatToRename = chat
                                    newTitle = chat.title
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }

                                Button(role: .destructive) {
                                    chatToDelete = chat
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            } label: {
                                Image(.moreIcon)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(height: 36)
                    }
                }
                .padding(.horizontal)
            }


            Spacer()

            if !Apphud.hasPremiumAccess() {
                VStack(spacing: 0) {
                    Divider()
                        .padding(.horizontal)
                    Button {
                        showPaywall = true
                    } label: {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.orangeF86B0D)
                                .frame(width: 44, height: 40)
                                .overlay {
                                    Image(.crownIcon)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            Text("Get premium")
                                .font(.interMedium(size: 16))
                                .foregroundStyle(.black101010)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 8)
                    }
                }
                .background(.white)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.white)

        // MARK: - Rename sheet
        .sheet(item: $chatToRename, onDismiss: { newTitle = "" }) { chat in
            RenameChatSheet(
                title: $newTitle,
                onCancel: { chatToRename = nil },
                onSave: {
                    let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { chatToRename = nil; return }
                    viewModel.store.renameChat(id: chat.id, to: trimmed)
                    chatToRename = nil
                }
            )
            .presentationDetents([.height(200)])
            .presentationCornerRadius(24)
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
        // MARK: - Delete confirmation
        .confirmationDialog(
            "Delete chat?",
            isPresented: Binding(
                get: { chatToDelete != nil },
                set: { if !$0 { chatToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let chat = chatToDelete else { return }

                // если удаляем выбранный — переедем на соседний
                if viewModel.selectedChat?.id == chat.id,
                   let idx = viewModel.store.chats.firstIndex(where: { $0.id == chat.id }) {

                    let nextIdx = max(0, min(idx, (viewModel.store.chats.count - 1)))
                    withAnimation {
                        viewModel.store.deleteChat(id: chat.id)                // 👈 сохраняем
                        viewModel.selectedChat = viewModel.store.chats[safe: nextIdx]
                    }
                } else {
                    withAnimation { viewModel.store.deleteChat(id: chat.id) }  // 👈 сохраняем
                }
                chatToDelete = nil
            }
            Button("Cancel", role: .cancel) { chatToDelete = nil }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct RenameChatSheet: View {
    @Binding var title: String
    var onCancel: () -> Void
    var onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rename")
                .font(.headline)

            TextField("Chat title", text: $title)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel", action: onCancel)
                Spacer()
                Button("Save", action: onSave)
                    .bold()
            }
        }
        .padding(20)
    }
}
