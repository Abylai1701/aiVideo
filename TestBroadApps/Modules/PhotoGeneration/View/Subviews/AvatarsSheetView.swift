//
//  AvatarsSheetView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 07.10.2025.
//

import Foundation
import SwiftUI
import Kingfisher

struct Avatar: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct AvatarSheetView: View {
    
    @Environment(\.dismiss) private var dismiss

    let avatars: [UserAvatar]
    @Binding var selectedAvatar: UserAvatar?

    let onCreateTap: () -> Void
    let onAvatarTap: (UserAvatar) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.black101010.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 8) {
                        Button(action: onCreateTap) {
                            Image(.addIcon)
                                .resizable()
                                .frame(width: 80, height: 80)
                        }
                        Text("Create an\navatar")
                            .multilineTextAlignment(.center)
                            .font(.interMedium(size: 16))
                            .foregroundStyle(.black101010)
                    }

                    ForEach(avatars) { avatar in
                        VStack(spacing: 8) {
                            Button {
                                onAvatarTap(avatar)
                                dismiss()
                            } label: {
                                KFImage(URL(string: avatar.preview ?? ""))
                                    .setProcessor(
                                        DownsamplingImageProcessor(size: CGSize(width: 100, height: 100))
                                    )
                                    .placeholder({
                                        ProgressView()
                                            .frame(width: 40, height: 40)
                                    })
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                avatar.id == selectedAvatar?.id ? Color.orangeF86B0D : .clear,
                                                lineWidth: 3
                                            )
                                    )
                                    .scaleEffect(avatar.id == selectedAvatar?.id ? 0.9 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedAvatar?.id)
                            }

                            Text(avatar.title ?? "Avatar \(avatar.id)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.leading)
            }
            Spacer()
        }
        .frame(height: 206)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 40))
    }
}
