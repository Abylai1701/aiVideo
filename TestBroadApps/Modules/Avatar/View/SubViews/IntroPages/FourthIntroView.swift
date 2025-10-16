//
//  FourthIntroView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 08.10.2025.
//

import SwiftUI

struct FourthIntroView: View {
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Upload from 10 to 50 photos")
                    .font(.interSemiBold(size: 26.fitW))
                    .foregroundStyle(.white)
                    .padding(.bottom, 16.fitH)
                
                Text("The more photos you upload, the better the neural network learns.")
                    .font(.interMedium(size: 16.fitW))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.bottom, 12.fitH)
            }
            .padding(.horizontal)

            Image(.introFourthIcon)
                .resizable()
                .padding(.bottom, 12.fitH)
            
            Text("You can create an album, gallery, or cloud storage where you will collect your photos and then come back and add them.")
                .font(.interMedium(size: 16.fitW))
                .foregroundStyle(.white)
                .padding(.bottom, 16.fitH)
                .padding(.horizontal)
        }
    }
}


#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(router: Router()))
}

