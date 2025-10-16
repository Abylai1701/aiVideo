//
//  AiPhotoView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 09.10.2025.
//

import SwiftUI
import Kingfisher

struct AiPhotoView: View {
    
    @ObservedObject var viewModel: AiPhotoViewModel
    
    @State private var showSheet: Bool = false
    @State var showAspectRatioSheet: Bool = false
    @State private var sharePayload: SharePayload?
    @State private var selectedAvatar: UserAvatar?
    @State private var showPaywall = false

    let mockAvatars: [Avatar] = [
        Avatar(name: "Ava1", imageName: "ava"),
        Avatar(name: "Ava2", imageName: "ava"),
        Avatar(name: "Ava3", imageName: "ava")
    ]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                header
                
                switch viewModel.step {
                case .opened:
                    firstStep
                case .generate:
                    secondStep
                case .result:
                    thirdStep
                }
            }
            
            if showSheet || showAspectRatioSheet {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                }
            }
            
            if viewModel.showAlert != .none {
                alertView
                    .zIndex(11)
            }
            
            if !showSheet && !showAspectRatioSheet {
                VStack {
                    Spacer()
                    bottomButtons
                }
                .zIndex(9)
                .transition(.move(edge: .bottom))
            }
            
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.step)
        .sheet(item: $sharePayload) { payload in
            ShareSheet(items: payload.items)
        }
        .hideKeyboardOnTap()
        .sheet(isPresented: $showSheet) {
            AvatarSheetView(
                avatars: viewModel.avatars,
                selectedAvatar: $selectedAvatar,
                onCreateTap: {
                    showSheet = false
                    viewModel.pushToCreateAvatar()
                },
                onAvatarTap: { avatar in
                    selectedAvatar = avatar
                }
            )
            .presentationDetents([.height(206)])
            .presentationCornerRadius(40)
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showAspectRatioSheet) {
            AspectRatioSheetView(
                selectedAspect: $viewModel.aspectRatio
            )
            .presentationDetents([.height(266)])
            .presentationCornerRadius(40)
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.showTokensPaywall) {
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
        .onAppear {
            if PurchaseManager.shared.isSubscribed {
                Task {
                    await viewModel.fetchUserInfo()
                }
            } else {
                showPaywall = true
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            if !PurchaseManager.shared.isSubscribed {
                viewModel.popToRoot()
            }
        } content: {
            PaywallView()
        }

    }
    
    private var firstStep: some View {
        VStack(spacing: .zero) {
            if let avatar = selectedAvatar?.preview {
                VStack {
                    ZStack {
                        Color.grayF5F5F5
                        
                        if let url = URL(string: avatar) {
                            KFImage(url)
                                .placeholder {
                                    ProgressView()
                                }
                                .cancelOnDisappear(true)
                                .resizable()
                                .scaledToFit()
                                .padding(.vertical)
                                .transition(.opacity)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height / 1.86)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    Spacer()
                }
                
            } else {
                Spacer()
                
                Image(.emptyImageIcon)
                    .resizable()
                    .frame(width: 113.fitW, height: 32.fitW)
                    .offset(y: -30.fitH)
                
                Spacer()
            }
        }
    }
    
    private var secondStep: some View {
        VStack(spacing: .zero) {
            ZStack {
                Color.grayF5F5F5
                
                Group {
                    if let preview = selectedAvatar?.preview,
                       let url = URL(string: preview) {
                        KFImage(url)
                            .placeholder { ProgressView() }
                            .cancelOnDisappear(true)
                            .resizable()
                            .scaledToFit()
                            .padding(.vertical)
                            .blur(radius: 5)
                            .transition(.opacity)
                    } else {
                        Image(.templateIcon)
                            .resizable()
                            .padding(.vertical)
                            .blur(radius: 5)
                    }
                }
                
                .frame(height: UIScreen.main.bounds.height / 1.4)

            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom)
        // MARK: - Вот тут изменить моменты жиес
        
        .overlay {
            VStack(spacing: .zero) {
                ProgressView()
                    .frame(width: 18, height: 18)
                    .tint(.white)
                    .background(
                        VisualEffectBlur(style: .systemThinMaterialDark)
                            .clipShape(.circle)
                            .frame(width: 40, height: 40)
                    )
                    .padding(.bottom)

                Text("The image is generated, wait for the end of the process…")
                    .font(.interMedium(size: 15))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 240, height: 58)
                    .padding(.horizontal, 8)
                    .background(
                        VisualEffectBlur(style: .systemThinMaterialDark)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    )
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    @ViewBuilder
    private var bottomButtons: some View {
        switch viewModel.step {
        case .opened:
            AiPhotoBottomButtons(
                aspectRatio: $viewModel.aspectRatio,
                prompt: $viewModel.prompt
            ) {
                showAspectRatioSheet = true
            } onAvatarTap: {
                showSheet = true
            } onGenerateTap: {
                if let avatar = selectedAvatar, !viewModel.prompt.isEmpty {
                    Task {
                        await viewModel.generatePhoto(avatar: avatar)
                    }
                }
            }

        case .generate:
            EmptyView()
        case .result:
            resultButtons
                .padding(.horizontal)
        }
    }
    
    // MARK: Third Step
    
    private var thirdStep: some View {
        VStack(spacing: .zero) {
            mainViewForThirdStep
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private var mainViewForThirdStep: some View {
        VStack {
            ZStack(alignment: .center) {
                Color.grayF5F5F5
                    KFImage(URL(string: viewModel.result?.result ?? ""))
                    .placeholder {
                        ProgressView()
                    }
                    .cancelOnDisappear(true)
                    .resizable()
                    .scaledToFit()
                    .transition(.opacity)
            }
            .frame(height: UIScreen.main.bounds.height / 1.63)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
    }
    
    private var resultButtons: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 24)
                .fill(.orangeF86B0D)
                .frame(height: 44.fitH)
                .overlay {
                    HStack {
                        Image(.downloadIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("Download")
                            .font(.interMedium(size: 16))
                            .foregroundStyle(.white)
                    }
                }
                .onTapGesture {
                    Task {
                        await viewModel.download()
                    }
                }
            
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .strokeBorder(Color.orangeF86B0D, lineWidth: 1.5)
                .frame(height: 44.fitH)
                .overlay {
                    HStack {
                        Image(.shareIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("Share")
                            .font(.interMedium(size: 16))
                            .foregroundStyle(.black101010)
                    }
                }
                .onTapGesture {
                    Task {
                        guard let image = await viewModel.downloadImage() else { return }
                        
                        if let data = image.jpegData(compressionQuality: 0.95) {
                            let url = FileManager.default.temporaryDirectory
                                .appendingPathComponent("effect-\(UUID().uuidString).jpg")
                            do {
                                try data.write(to: url, options: .atomic)
                                await MainActor.run {
                                    sharePayload = SharePayload(items: [url])
                                }
                                return
                            } catch {
                                print("⚠️ write temp failed:", error.localizedDescription)
                            }
                        }
                        await MainActor.run {
                            sharePayload = SharePayload(items: [image])
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    private var alertView: some View {
        switch viewModel.showAlert {
        case .error:
            CustomAlertGenerationError(
                title: "Generation error",
                message: "Something went wrong. Try again",
                primaryButtonTitle: "Cancel",
                onPrimary: {
                    viewModel.showAlert = .none
                },
                secondaryButtonTitle: "Retry") {
                    print("Повторить")
                }
        case .save:
            CustomAlertView(
                title: "Saved",
                message: "The file has been successfully saved.",
                primaryButtonTitle: "Done"
            ) {
                viewModel.showAlert = .none
            }
        case .failed:
            CustomAlertView(
                title: "Failed",
                message: "The file could not be saved.",
                primaryButtonTitle: "Done"
            ) {
                viewModel.showAlert = .none
            }
        case .none:
            EmptyView()
        case .delete:
            CustomAlertDelete {
                viewModel.showAlert = .none
            } onSecondary: {
                print("Delete")
            }

        }
    }
    
    private var header: some View {
        HStack {
            Image(.backIcon)
                .resizable()
                .frame(width: 48.fitW, height: 48.fitW)
                .onTapGesture {
                    switch viewModel.step {
                    case .opened:
                        selectedAvatar = nil
                        viewModel.popToRoot()
                    case .generate:
                        selectedAvatar = nil
                        viewModel.popToRoot()
                    case .result:
                        selectedAvatar = nil
                        viewModel.popToRoot()
                    }
                }
            Spacer()
            
            Text("Image generation")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(.black101010)
            
            Spacer()

            RoundedRectangle(cornerRadius: 24)
                .fill(.orangeF86B0D)
                .frame(width: 67, height: 40)
                .overlay {
                    HStack {
                        Image(.generateIcon)
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("\(viewModel.tokensCount)")
                            .font(.interMedium(size: 16))
                            .foregroundStyle(.white)
                    }
                }
            
        }
        .padding(.horizontal)
        
    }
}

#Preview {
    AiPhotoView(viewModel: AiPhotoViewModel(router: Router()))
}
