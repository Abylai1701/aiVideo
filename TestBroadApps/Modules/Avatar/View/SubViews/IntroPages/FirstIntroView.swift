//
//  FirstIntroView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 07.10.2025.
//

import SwiftUI

struct FirstIntroView: View {
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Select Photos")
                    .font(.interSemiBold(size: 26.fitW))
                    .foregroundStyle(.white)
                    .padding(.bottom, 16.fitH)
                
                HStack(alignment: .top, spacing: 8) {
                    Image(.starIcon)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .offset(y: 2)
                    
                    Text("In different conditions: from different angles, in different lighting conditions, and in different locations")
                        .font(.interMedium(size: 16.fitW))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.bottom, 16.fitH)
                
                HStack(alignment: .top, spacing: 8) {
                    Image(.starIcon)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .offset(y: 2)
                    
                    Text("Appearance features: hairstyle, makeup, face, colors")
                        .font(.interMedium(size: 16.fitW))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.bottom, 43.fitH)
            }
            
            Image(.introFirstIcon)
                .resizable()
                .padding(.horizontal, 20.fitW)
                .padding(.bottom, 41.fitH)
        }
        .padding(.horizontal)
    }
}


#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(router: Router()))
}
