//
//  CreateAvatarView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 07.10.2025.
//

import SwiftUI
import PhotosUI

struct CreateAvatarView: View {
    
    @ObservedObject var viewModel: CreateAvatarViewModel
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: .zero) {
                header
                pages
                continueButton
            }
            
            showSelectedPhoto
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .overlay {
            alertView
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.introPageIndex)
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItems,
            matching: .images
        )
        .onChange(of: selectedPhotoItems) { newItems, _ in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.photos.append(image)
                    }
                }
                selectedPhotoItems.removeAll()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.fetchUserInfo()
            }
        }
        .sheet(isPresented: $viewModel.showAvatarPaywall) {
            Task {
                await viewModel.fetchUserInfo()
            }
        } content: {
            AvatarPaywall() {
                Task {
                    await viewModel.fetchUserInfo()
                }
            }
            .presentationDetents([.height(420)])
            .presentationCornerRadius(32)
            .presentationDragIndicator(.hidden)
        }
    }
    
    @ViewBuilder
    private var pages: some View {
        switch viewModel.step {
        case .intro:
            switch viewModel.introPageIndex {
            case 0:
                FirstIntroView()
            case 1:
                SecondIntroView()
            case 2:
                ThirdIntroView()
            case 3:
                FourthIntroView()
            default:
                FirstIntroView()
            }
        case .genderSelect:
            GenderPickView(selectedGender: $viewModel.gender)
        case .nameInput:
            NameAvatarView(avatarName: $viewModel.avatarName)
        case .photoUpload:
            UploadPhotosView(photos: $viewModel.photos, selectedImage: $selectedImage)
        case .generating:
            GeneratingAvatarView()
        case .showResult:
            AvatarResult(url: URL(string: viewModel.result?.preview ?? ""))
        case .showErrors:
            EmptyView()
        }
    }
    @ViewBuilder
    private var header: some View {
        switch viewModel.step {
        case .intro:
            HeaderForIntro {
                viewModel.skip()
            } popAction: {
                viewModel.back()
            }
            .padding(.bottom, 24.fitH)

        case .genderSelect:
            HeaderForGender {
                viewModel.back()
            }
            .padding(.bottom, 24.fitH)

        case .nameInput:
            HeaderForGender {
                viewModel.back()
            }
            .padding(.bottom, 24.fitH)

        case .photoUpload:
            HeaderForUpload(countOfPhotos: viewModel.photos.count, countOfAvatars: $viewModel.avatarTokens) {
                viewModel.back()
            }
            .padding(.bottom, 24.fitH)

        case .generating:
            HeaderForGeneration(countOfAvatars: $viewModel.avatarTokens) {
                viewModel.back()
            }
            .padding(.bottom, 16.fitH)

        case .showResult:
            HeaderForGeneration(countOfAvatars: $viewModel.avatarTokens) {
                viewModel.back()
            }
            .padding(.bottom, 16.fitH)
        case .showErrors:
            HeaderForGeneration(countOfAvatars: $viewModel.avatarTokens) {
                viewModel.back()
            }
        }
    }
    
    @ViewBuilder
    private var continueButton: some View {
        switch viewModel.step {
        case .intro:
            ContinueButtonIntro() {
                viewModel.next()
            }
        case .genderSelect:
            ContinueButtonGender() {
                viewModel.next()
            }
        case .nameInput:
            ContinueButtonName(isDisabled: viewModel.avatarName.isEmpty) {
                viewModel.next()
            }
        case .photoUpload:
            ContinueButtonUpload(
                photoCount: viewModel.photos.count,
                onAddTap: {
                    showPhotoPicker = true
                },
                onDoneTap: {
                    viewModel.next()
                }
            )
        case .generating:
            EmptyView()
        case .showResult:
            ContinueButtonResult {
                Task {
                    await viewModel.generateAvatar()
                }
            } onToTheAvatar: {
                viewModel.back()
            }

        case .showErrors:
            EmptyView()
        }
    }
    private var backgroundColor: Color {
        switch viewModel.step {
        case .intro:
                .orangeF86B0D
        default:
                .white
        }
    }
    
    @ViewBuilder
    private var showSelectedPhoto: some View {
        if let image = selectedImage {
            ZStack {
                VisualEffectBlur(style: .systemUltraThinMaterialDark)
                    .ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .transition(.scale)
                    .zIndex(2)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedImage = nil
                            }
                        } label: {
                            ZStack {
                                VisualEffectBlur(style: .systemMaterialDark)
                                    .clipShape(Circle())
                                    .frame(width: 32, height: 32)
                                Image(.littleCloseIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                            }
                        }
                        .padding(8)
                    }
                    .padding()

            }
            .transition(.opacity)
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


#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(router: Router()))
}
