//
//  CustomAlert.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 06.10.2025.
//

import SwiftUI

struct CustomAlertView: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let onPrimary: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: .zero) {
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

                VStack(spacing: .zero) {
                    Button(action: {
                        onPrimary()
                    }) {
                        Text(primaryButtonTitle)
                            .fontWeight(.semibold)
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
