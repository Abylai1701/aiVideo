//
//  ThirdIntroView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 08.10.2025.
//

import SwiftUI

struct ThirdIntroView: View {
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("We recommend \nthat you do not use")
                    .font(.interSemiBold(size: 26.fitW))
                    .foregroundStyle(.white)
                    .padding(.bottom, 16.fitH)
                
                HStack(alignment: .top, spacing: 8) {
                    Image(.errorIcon)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .offset(y: 2)
                    
                    Text("Photos from social networks, as they are highly compressed")
                        .font(.interMedium(size: 16.fitW))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.bottom, 16.fitH)
                
                HStack(alignment: .top, spacing: 8) {
                    Image(.errorIcon)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .offset(y: 2)
                    
                    Text("Low—resolution photo - the avatar may turn out to be of poor quality")
                        .font(.interMedium(size: 16.fitW))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.bottom, 43.fitH)
            }
            
            Image(.introThirdIcon)
                .resizable()
                .padding(.horizontal, 28.fitW)
                .padding(.bottom, 64.fitH)
        }
        .padding(.horizontal)
    }
}


#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(router: Router()))
}
