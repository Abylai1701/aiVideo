//
//  SecondIntroView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 07.10.2025.
//

import SwiftUI

struct SecondIntroView: View {
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Do not upload photos where:")
                    .font(.interSemiBold(size: 26.fitW))
                    .foregroundStyle(.white)
                    .padding(.bottom, 16.fitH)
                
                HStack(alignment: .top, spacing: 8) {
                    Image(.littleCloseIcon)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .offset(y: 2)
                    
                    Text("There are several people in the frame")
                        .font(.interMedium(size: 16.fitW))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.bottom, 16.fitH)
                
                HStack(alignment: .top, spacing: 8) {
                    Image(.littleCloseIcon)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .offset(y: 2)
                    
                    Text("Вad angle")
                        .font(.interMedium(size: 16.fitW))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.bottom, 16.fitH)
                
                HStack(alignment: .top, spacing: 8) {
                    Image(.littleCloseIcon)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .offset(y: 2)
                    
                    Text("The face is too small")
                        .font(.interMedium(size: 16.fitW))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.bottom, 16.fitH)
                
                
                HStack(alignment: .top, spacing: 8) {
                    Image(.littleCloseIcon)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .offset(y: 2)
                    
                    Text("Poor lighting")
                        .font(.interMedium(size: 16.fitW))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.bottom, 16.fitH)
            }
            
            Image(.introSecondIcon)
                .resizable()
                .padding(.horizontal, 15.fitW)
                .padding(.bottom, 48.fitH)
        }
        .padding(.horizontal)
    }
}

#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(router: Router()))
}
