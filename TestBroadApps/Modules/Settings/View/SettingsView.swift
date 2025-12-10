//
//  SettingsView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//

import SwiftUI
import Kingfisher
import PhotosUI
import ApphudSDK

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    @State private var notificationsEnabled = false
    @State private var didInitializeNotifications = false
    @State private var touchTheNotufy = false
    
    @State private var showSheet: Bool = false
    @State private var selectedAvatar: UserAvatar?
    
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    @State private var showAlert = false
    @State private var showPaywall = false
    
    @State private var showPolicy = false
    @State private var showTerms = false
    
    var body: some View {
        content
            .overlay {
                if showSheet {
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
                AvatarOptionsSheetView { newTitle in
                    Task {
                        if let avatar = selectedAvatar {
                            await viewModel.updateAvatarTitle(
                                avatar: avatar,
                                newName: newTitle)
                            await MainActor.run { showSheet = false }
                        }
                    }
                } change: {
                    showSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showPhotoPicker = true
                    }
                } delete: {
                    Task {
                        if let avatar = selectedAvatar {
                            await viewModel.deleteAvatar(avatarId: avatar.id)
                            await MainActor.run {
                                showSheet = false
                                selectedAvatar = nil
                            }
                        }
                    }
                }
                .presentationDetents([.height(230)])
                .presentationCornerRadius(40)
                .presentationDragIndicator(.hidden)
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedPhotoItem,
                matching: .images
            )
            .onChange(of: selectedPhotoItem) { newItem, _ in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data),
                       let avatar = selectedAvatar {
                        await viewModel.updateAvatarPreview(avatarId: avatar.id, image: image)
                    }
                    selectedPhotoItem = nil
                }
            }
            .task {
                notificationsEnabled = await NotificationService.shared.getNotificationStatus()
            }
            .onChange(of: notificationsEnabled) { newValue, oldValue in
                if !didInitializeNotifications {
                    didInitializeNotifications = true
                    return
                }
                
                Task {
                    if !newValue {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    }
                    
                    if oldValue != newValue {
                        NotificationService.shared.openSystemSettings()
                    }
                    let status = await NotificationService.shared.getNotificationStatus()
                    await MainActor.run {
                        notificationsEnabled = status
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                Task {
                    let status = await NotificationService.shared.getNotificationStatus()
                    await MainActor.run {
                        if notificationsEnabled != status {
                            didInitializeNotifications = false
                        }
                        notificationsEnabled = status
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchUserInfo()
                    viewModel.fetchAvatars()
                }
            }
            .alert(isPresented: $showAlert) {
                return Alert(
                    title: Text("Your subscription is active "),
                    message: Text(""),
                    dismissButton: .default(Text("OK"))
                )
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
            .safari(urlString: "https://docs.google.com/document/d/1l17QMMa0Hjz4ycyAGM9Qj_yIL-Zt-qSAqYW2qdHucW4/edit?usp=sharing", isPresented: $showPolicy)
            .safari(urlString: "https://docs.google.com/document/d/1sM80Feufp8jTebygWDq-rj00Ju19fRSkI9GWaodUeRA/edit?usp=sharing", isPresented: $showTerms)
    }
    
    private var content: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: .zero) {
                HStack(alignment: .center) {
                    Text("Settings")
                        .font(.interSemiBold(size: 26))
                        .foregroundStyle(.black101010)
                        .fixedSize()
                    
                    Spacer(minLength: 8)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(.generateIcon)
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            Text("\(viewModel.imageTokens)")
                                .font(.interMedium(size: 16))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.orangeF86B0D)
                        )
                        
                        HStack(spacing: 4) {
                            Image(.whiteAvatarIcon)
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            Text("\(viewModel.avatarTokens)")
                                .font(.interMedium(size: 16))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.purple892FFF)
                        )
                    }
                }
                .padding(.bottom, 32.fitH)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Button {
                                if Apphud.hasPremiumAccess() {
                                    viewModel.pushToCreateAvatar()
                                } else {
                                    showPaywall = true
                                }
                            } label: {
                                Image(.addIcon)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                            }
                            Text("Add an avatar")
                                .font(.interMedium(size: 16))
                                .foregroundStyle(.black101010)
                        }
                        avatars
                    }
                    .padding(.bottom, 24.fitH)
                }
                
                subSection
                    .padding(.bottom)
                
                VStack(spacing: .zero) {
                    SettingsToggleRow(
                        icon: .init(.notifyIcon),
                        title: "Notifications",
                        isOn: $notificationsEnabled
                    )
                }
                .padding(.bottom)
                
                thirdSection
                
                Spacer(minLength: 40)
            }
            .padding(.top, 8)
            .padding(.horizontal)
        }
    }
    
    private var avatars: some View {
        ForEach(viewModel.avatars, id: \.id) { avatar in
            VStack(spacing: 8) {
                ZStack {
                    KFImage(URL(string: avatar.preview ?? ""))
                        .setProcessor(
                            DownsamplingImageProcessor(size: CGSize(width: 150, height: 150))
                        )
                        .placeholder({
                            ProgressView()
                                .frame(width: 60, height: 60)
                        })
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    
                    Image(.optionIcon)
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                .onTapGesture {
                    selectedAvatar = avatar
                    showSheet = true
                    print("Avatar selected")
                }
                
                Text(avatar.title ?? "Avatar")
                    .font(.interMedium(size: 16))
                    .foregroundStyle(.black101010)
            }
        }
    }
    private var subSection: some View {
        VStack(spacing: .zero) {
            HStack(spacing: 8) {
                Image(.diamondIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text("Management your subscription")
                    .font(.interMedium(size: 16))
                    .foregroundStyle(.black101010)
                
                Spacer()
                
                Image(.arrowRight)
                    .resizable()
                    .frame(width: 20, height: 20)
                
            }
            .padding(.horizontal, 12)
            .frame(height: 52)
            .contentShape(Rectangle())
            .onTapGesture {
                if Apphud.hasPremiumAccess() {
                    showAlert = true
                } else {
                    showPaywall = true
                }
            }
            
            Divider()
                .background(.grayF5F5F5.opacity(0.1))
                .padding(.leading, 39.fitW)
            
            HStack(spacing: 8) {
                Image(.renewIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text("Renew your subscription")
                    .font(.interMedium(size: 16))
                    .foregroundStyle(.black101010)
                
                Spacer()
                
                Image(.arrowRight)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 12)
            .frame(height: 52)
            .contentShape(Rectangle())
            .onTapGesture {
                Task {
                    await PurchaseManager.shared.restore()
                }
            }
        }
        .background(.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var thirdSection: some View {
        VStack(spacing: .zero) {
            HStack(spacing: 8) {
                Image(.termsIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text("Terms of Use")
                    .font(.interMedium(size: 16))
                    .foregroundStyle(.black101010)
                
                Spacer()
                
                Image(.arrowRight)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 12)
            .frame(height: 52)
            .contentShape(Rectangle())
            .onTapGesture {
                showTerms = true
            }
            
            Divider()
                .background(.grayF5F5F5.opacity(0.1))
                .padding(.leading, 39.fitW)
            
            HStack(spacing: 8) {
                Image(.privacyIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text("Privacy Policy")
                    .font(.interMedium(size: 16))
                    .foregroundStyle(.black101010)
                
                Spacer()
                
                Image(.arrowRight)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 12)
            .frame(height: 52)
            .contentShape(Rectangle())
            .onTapGesture {
                showPolicy = true
            }
            
            Divider()
                .background(.grayF5F5F5.opacity(0.1))
                .padding(.leading, 39.fitW)
            
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.black101010)
                    .offset(y: -1)
                
                Text("Rate App")
                    .font(.interMedium(size: 16))
                    .foregroundStyle(.black101010)
                
                Spacer()
                
                Image(.arrowRight)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 12)
            .frame(height: 52)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.pushToRate()
            }
        }
        .background(.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(router: Router()))
}
