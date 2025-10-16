//
//  GenderPickView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 08.10.2025.
//

import SwiftUI

struct GenderPickView: View {
    
    @Binding var selectedGender: Gender?

    var body: some View {
        VStack(alignment: .center) {
            Text("Сhoose the gender of your avatar")
                .font(.interSemiBold(size: 26.fitW))
                .foregroundStyle(.black101010)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30.fitW)
                .padding(.bottom, 16.fitH)
            
            Text("This will help you create your own personal avatar.")
                .font(.interMedium(size: 16.fitW))
                .foregroundStyle(.black101010.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 70.fitW)
            
            Spacer()
            
            HStack(spacing: 8.fitW) {
                genderCard(.woman, image: "woman")
                genderCard(.man, image: "man")
            }
            
        }
        .padding(.horizontal)
        .padding(.bottom, 24.fitH)
    }
    
    @ViewBuilder
    private func genderCard(_ gender: Gender, image: String) -> some View {
        let isSelected = selectedGender == gender
        
        ZStack {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 167.fitW, height: 300.fitH)
        }
        .overlay(alignment: .bottom) {
            HStack {
                Circle()
                    .strokeBorder(Color.orangeF86B0D, lineWidth: 1)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.orangeF86B0D : .clear)
                            .frame(width: 12, height: 12)
                    )
                    .frame(width: 24, height: 24)
                
                Text(gender.rawValue)
                    .font(.interMedium(size: 16))
                    .foregroundStyle(.white)
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(4)
            .onTapGesture {
                withAnimation(.easeInOut) {
                    selectedGender = gender
                }
            }
        }
    }
}


#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(router: Router()))
}
