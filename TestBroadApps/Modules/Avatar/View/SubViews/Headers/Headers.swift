//
//  Headers.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 07.10.2025.
//

import SwiftUI

struct HeaderForIntro: View {
    var skipTapAction: () -> Void
    var popAction: () -> Void
    
    var body: some View {
        HStack {
            Image(.backIcon)
                .resizable()
                .frame(width: 48.fitW, height: 48.fitW)
                .onTapGesture {
                    popAction()
                }
                       
            Spacer()

            Text("Skip")
                .font(.interSemiBold(size: 16))
                .foregroundStyle(.white.opacity(0.8))
                .onTapGesture {
                    skipTapAction()
                }
        }
        .overlay {
            Text("Creating an avatar")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(.white)
            
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

struct HeaderForGender: View {
    var popAction: () -> Void
    
    var body: some View {
        HStack {
            Image(.backIcon)
                .resizable()
                .frame(width: 48.fitW, height: 48.fitW)
                .onTapGesture {
                    popAction()
                }
     
            Spacer()
        }
        .overlay {
            Text("Creating an avatar")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(.black101010)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

struct HeaderForUpload: View {
    var countOfPhotos: Int
    @Binding var countOfAvatars: Int
    var popAction: () -> Void
    
    var body: some View {
        HStack {
            Image(.backIcon)
                .resizable()
                .frame(width: 48.fitW, height: 48.fitW)
                .onTapGesture {
                    popAction()
                }
     
            Spacer()
            
            Text("Added: \(countOfPhotos)")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(.black101010)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 24)
                .fill(.purple892FFF)
                .frame(width: 67, height: 40)
                .overlay {
                    HStack {
                        Image(.whiteAvatarIcon)
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("\(countOfAvatars)")
                            .font(.interMedium(size: 16))
                            .foregroundStyle(.white)
                    }
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(router: Router()))
}

struct HeaderForGeneration: View {
    @Binding var countOfAvatars: Int
    var popAction: () -> Void

    var body: some View {
        HStack {
            Image(.backIcon)
                .resizable()
                .frame(width: 48.fitW, height: 48.fitW)
                .onTapGesture {
                    popAction()
                }
     
            Spacer()
            
            Text("Avatar generation")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(.black101010)
            
            Spacer(minLength: 0)
            
            HStack(spacing: 4) {
                Image(.generateIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text("\(countOfAvatars)")
                    .font(.interMedium(size: 16))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.purple892FFF)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}
