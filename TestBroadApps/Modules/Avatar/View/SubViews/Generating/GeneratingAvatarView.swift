//
//  GeneratingAvatarView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 08.10.2025.
//

import SwiftUI

struct GeneratingAvatarView: View {
    var body: some View {
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
                
                Text("The image has been generated. Please wait for the process to complete or check it later in the settings...")
                    .font(.interMedium(size: 15))
                    .foregroundStyle(.black101010.opacity(0.7))
                    .padding(.horizontal, 48.fitW)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(router: Router()))
}
