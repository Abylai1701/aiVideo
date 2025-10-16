//
//  OnboardingView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 12.10.2025.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    
    @State private var step: Int = 0
    @State private var isShowingAlert: Bool = false
    
    var closeOnboard: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.orangeF86B0D
                .ignoresSafeArea()

            if step == 0 {
                VStack {
                    Image(.onb1)
                        .resizable()
                        
                    bottomButtonFirst
                }
                .ignoresSafeArea()

            } else if step == 1 {
                VStack {
                       Spacer()
                       Spacer()
                       Image(.onb2)
                           .resizable()
                           .frame(width: 319.fitW, height: 319.fitW)
                           .padding(.horizontal)
                       Spacer()
                       
                       bottomButtonSecond
                   }
                .ignoresSafeArea()

            } else if step == 2 {
                VStack {
                    Spacer()
                    Spacer()
                    
                    Image(.onb3)
                        .resizable()
                        .frame(width: 319.fitW, height: 319.fitW)
                        .padding(.horizontal)
                    Spacer()
                    bottomButtonThird
                }
                .ignoresSafeArea()

            }
        }
        .overlay(alignment: .top) {
            if step == 0 {
                headerFirst
            } else if step == 1 {
                headerSecond
            } else if step == 2 {
                headerThird
            }
        }
    }
    
    private var headerFirst: some View {
        HStack {
            Spacer()

            Text("Skip")
                .font(.interSemiBold(size: 16))
                .foregroundStyle(.white.opacity(0.8))
                .onTapGesture {
                    step = 2
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48.fitW)
        .padding(.horizontal)
    }
    
    private var headerSecond: some View {
        HStack {
            Image(.backIcon)
                .resizable()
                .frame(width: 48.fitW, height: 48.fitW)
                .onTapGesture {
                    step = 0
                }
                       
            Spacer()

            Text("Skip")
                .font(.interSemiBold(size: 16))
                .foregroundStyle(.white.opacity(0.8))
                .onTapGesture {
                    step = 2
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    private var headerThird: some View {
        HStack {
            Image(.backIcon)
                .resizable()
                .frame(width: 48.fitW, height: 48.fitW)
                .onTapGesture {
                    step = 1
                }
                       
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    private var bottomButtonFirst: some View {
        VStack(alignment: .center) {
            Text("Welcome to App")
                .font(.interSemiBold(size: 26))
                .foregroundStyle(.black101010)
                .padding(.bottom)
            
            Text("Generate unique images and videos in seconds using a neural network")
                .font(.interMedium(size: 16))
                .foregroundStyle(.black101010.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40.fitW)
                .padding(.bottom, 24)

            Button {
                step = 1
            } label: {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.orangeF86B0D)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .overlay {
                        Text("Continue")
                            .font(.interMedium(size: 16))
                            .foregroundStyle(.white)
                    }
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
        .padding(.top, 32)
        .background(.white)
        .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
    }
    
    private var bottomButtonSecond: some View {
        VStack(alignment: .center) {
            Text("Transform your photo using effects")
                .font(.interSemiBold(size: 26))
                .foregroundStyle(.black101010)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30.fitW)
                .padding(.bottom)
            
            Text("Turn ordinary moments into unique digital art in one tap")
                .font(.interMedium(size: 16))
                .foregroundStyle(.black101010.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40.fitW)
                .padding(.bottom, 24)

            Button {
                step = 2
            } label: {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.orangeF86B0D)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .overlay {
                        Text("Continue")
                            .font(.interMedium(size: 16))
                            .foregroundStyle(.white)
                    }
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
        .padding(.top, 32)
        .background(.white)
        .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
    }

    private var bottomButtonThird: some View {
        VStack(alignment: .center) {
            Text("Go viral with new trends")
                .font(.interSemiBold(size: 26))
                .foregroundStyle(.black101010)
                .padding(.bottom)
            
            Text("Get noticed with trending effects every day.")
                .font(.interMedium(size: 16))
                .foregroundStyle(.black101010.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40.fitW)
                .padding(.bottom, 24)

            Button {
                closeOnboard()
            } label: {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.orangeF86B0D)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .overlay {
                        Text("Start")
                            .font(.interMedium(size: 16))
                            .foregroundStyle(.white)
                    }
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
        .padding(.top, 32)
        .background(.white)
        .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
    }
}
