//
//  PhotoGenView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI
import Kingfisher

struct PhotoGenView: View {
    
    @StateObject private var viewModel: PhotoGenViewModel
    
    init(router: Router, photo: String?, prompt: String?, templateId: Int?) {
        _viewModel = StateObject(
            wrappedValue: PhotoGenViewModel(
                router: router,
                photo: photo,
                prompt: prompt,
                templateId: templateId
            )
        )
    }
    
    @State private var showSheet: Bool = false
    @State private var sharePayload: SharePayload?
    @State private var selectedAvatar: UserAvatar?
    
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
            if viewModel.showAlert != .none {
                VisualEffectBlur(style: .systemThickMaterialDark)
                    .ignoresSafeArea()
                    .opacity(0.6)
                    .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.5), value: viewModel.step)
        .overlay {
            alertView
        }
        .overlay {
            if showSheet {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                }
            }
        }
        .sheet(item: $sharePayload) { payload in
            ShareSheet(items: payload.items)
        }
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
    }
    
    private var header: some View {
        HStack {
            Image(.backIcon)
                .resizable()
                .frame(width: 48.fitW, height: 48.fitW)
                .onTapGesture {
                    switch viewModel.step {
                    case .opened:
                        viewModel.pop()
                    case .generate:
                        viewModel.popToRoot()
                    case .result:
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
        .padding(.bottom)
    }
    // MARK: First Step
    
    private var firstStep: some View {
        VStack(spacing: .zero) {
            mainView
                .padding(.horizontal)
            
            Spacer()
            
            bottomButtons
                .padding(.horizontal)
        }
    }
    
    private var mainView: some View {
        ZStack {
            Color.grayF5F5F5
            
            KFImage(URL(string: viewModel.photo ?? ""))
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .frame(height: UIScreen.main.bounds.height / 2)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var bottomButtons: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .strokeBorder(Color.orangeF86B0D, lineWidth: 1.5)
                .frame(height: 44.fitH)
                .overlay {
                    HStack {
                        Image(.avatarIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("Use avatar")
                            .font(.interMedium(size: 16))
                            .foregroundStyle(.black101010)
                    }
                }
                .onTapGesture {
                    showSheet = true
                }
            
            RoundedRectangle(cornerRadius: 24)
                .fill((selectedAvatar == nil) ? .orangeF86B0D.opacity(0.5) : .orangeF86B0D)
                .frame(height: 44.fitH)
                .overlay {
                    HStack {
                        Image(.generateIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("Generate")
                            .font(.interMedium(size: 16))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.bottom)
                .onTapGesture {
                    Task {
                        if let avatar = selectedAvatar {
                            await viewModel.generatePhoto(avatar: avatar)
                        }
                    }
                }
                .disabled((selectedAvatar == nil))
        }
    }
    
    // MARK: Second Step
    
    private var secondStep: some View {
        VStack(spacing: .zero) {
            ZStack {
                Color.grayF5F5F5
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom)
        .overlay {
            VStack(spacing: .zero) {
                ProgressView()
                    .frame(width: 18, height: 18)
                    .tint(.black101010)
                    .padding(.bottom)
                
                Text("The image is generated, wait for the end of the process")
                    .font(.interMedium(size: 15))
                    .foregroundStyle(.black101010.opacity(0.7))
                    .padding(.horizontal, 48.fitW)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: Third Step
    
    private var thirdStep: some View {
        VStack(spacing: .zero) {
            mainViewForThirdStep
                .padding(.horizontal)
            
            Spacer()
            
            resultButtons
                .padding(.horizontal)
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
}
