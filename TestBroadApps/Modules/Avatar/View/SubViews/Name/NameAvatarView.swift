//
//  NameAvatarView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 08.10.2025.
//

import SwiftUI

struct NameAvatarView: View {
    @Binding var avatarName: String

    var body: some View {
        VStack(spacing: .zero) {
            Text("Come up with a name\nfor your avatar")
                .font(.interSemiBold(size: 26))
                .foregroundStyle(.black101010)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48.fitW)
                .padding(.bottom, 16.fitH)
            
            TextField("Avatar name", text: $avatarName)
                .font(.interMedium(size: 16))
                .padding()
                .frame(height: 50)
                .background(Color.grayF5F5F5)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

            Spacer()

            Image(.nameAvatarIcon)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 28.fitW)
                .padding(.bottom, 70.fitH)
        }
        .hideKeyboardOnTap()
    }
}

#Preview {
    NameAvatarView(avatarName: .constant(""))
}
