//
//  CustomAlertDelete.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 09.10.2025.
//

import SwiftUI

struct CustomAlertDelete: View {
    let onPrimary: () -> Void
    var onSecondary: (() -> Void)
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: .zero) {
                Text("Delete an item")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Text("This action cannot be undone.")
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
                        Text("Cancel")
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
                        Text("Delete")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.redFF3B30)
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
        CustomAlertDelete {
            print("")
        } onSecondary: {
            print("")
        }

    }
}
