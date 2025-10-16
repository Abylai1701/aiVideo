//
//  CustomAlertGenerationError.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 06.10.2025.
//

import Foundation

import SwiftUI

struct CustomAlertGenerationError: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let onPrimary: () -> Void
    var secondaryButtonTitle: String
    var onSecondary: (() -> Void)
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: .zero) {
                Image(.errorRedIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 2)
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)

                RoundedRectangle(cornerRadius: 1)
                    .fill(.gray.opacity(0.8))
                    .frame(height: 0.5)
                    
                HStack {
                    Button(action: {
                        onPrimary()
                    }) {
                        Text(primaryButtonTitle)
                            .font(.system(size: 17, weight: .regular))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.blue0A84FF)
                    }
                    .frame(height: 44)
                    
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.gray.opacity(0.5))
                        .frame(height: 44)
                        .frame(width: 0.4)
                    
                    Button(action: {
                        onSecondary()
                    }) {
                        Text(secondaryButtonTitle)
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.blue0A84FF)
                    }
                    .frame(height: 44)
                    
                }
            }
            .padding(.top, 20)
            .background(VisualEffectBlur(style: .systemChromeMaterialDark))
            .cornerRadius(16)
            .padding(52.fitW)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

#Preview {
    
    ZStack {
        CustomAlertGenerationError(
            title: "Generation error",
            message: "Something went wrong. Try again",
            primaryButtonTitle: "Cancel",
            onPrimary: {
                print("")
            },
            secondaryButtonTitle: "Retry") {
                print(")")
            }
    }
}
