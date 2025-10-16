//
//  ContinueButtons.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 07.10.2025.
//

import SwiftUI

struct ContinueButtonName: View {
    var isDisabled: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button {
            if !isDisabled {
                onTap()
            }
        } label: {
            Text("Continue")
                .font(.interMedium(size: 16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: 44)
                .background(isDisabled ? Color.orangeF86B0D.opacity(0.5) : Color.orangeF86B0D)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct ContinueButtonGender: View {
    var onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Text("Continue")
                .font(.interMedium(size: 16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: 44)
                .background(Color.orangeF86B0D)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct ContinueButtonIntro: View {
    var onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Text("Continue")
                .font(.interMedium(size: 16))
                .foregroundStyle(.black101010)
                .frame(maxWidth: .infinity, maxHeight: 44)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct ContinueButtonUpload: View {
    var photoCount: Int
    var onAddTap: () -> Void
    var onDoneTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button {
                onAddTap()
            } label: {
                Text("Add a photo")
                    .font(.interMedium(size: 16))
                    .foregroundColor(.orangeF86B0D)
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .contentShape(Rectangle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.orangeF86B0D, lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)

            Button {
                onDoneTap()
            } label: {
                Text("Done")
                    .font(.interMedium(size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .background(
                        photoCount >= 10
                        ? Color.orangeF86B0D
                        : Color.orangeF86B0D.opacity(0.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .disabled(photoCount < 10)
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct ContinueButtonResult: View {
    var onGenerateAgain: () -> Void
    var onToTheAvatar: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button {
                onGenerateAgain()
            } label: {
                Text("Generate again")
                    .font(.interMedium(size: 16))
                    .foregroundColor(.orangeF86B0D)
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .contentShape(Rectangle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.orangeF86B0D, lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)

            Button {
                onToTheAvatar()
            } label: {
                Text("To the avatar")
                    .font(.interMedium(size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .background( Color.orangeF86B0D)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(router: Router()))
}
