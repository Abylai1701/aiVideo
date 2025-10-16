//
//  AvatarPaywall.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 16.10.2025.
//

import SwiftUI

struct AvatarPaywall: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel = PurchaseManager.shared
    var onSuccess: () -> Void
    
    @State private var showWebView = false
    @State private var webTitle = ""
    @State private var webURL: URL? = nil
    
    @State private var selectedSubscriptionID: String = "2_avatar_69.99"
    
    
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            Capsule()
                .fill(Color.black101010.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            Text("Additional avatar")
                .font(.interSemiBold(size: 22))
                .foregroundStyle(.black101010)
                .padding(.bottom, 12)
            
            Text("Create an avatar for your friends and family")
                .font(.interMedium(size: 16))
                .foregroundStyle(.black101010.opacity(0.7))
                .padding(.bottom, 24)
            
            Image(.humans)
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .padding(.bottom, 24)
            
            SubscriptionOptionView(
                title: "1 avatar",
                subtitle: "",
                price: "$39.99",
                isSelected: selectedSubscriptionID == "1_avatar_39.99"
            )
            .onTapGesture {
                selectedSubscriptionID = "1_avatar_39.99"
            }
            .padding(.bottom, 8)
            
            SubscriptionOptionView(
                title: "2 avatar",
                subtitle: "",
                price: "$69.99",
                isSelected: selectedSubscriptionID == "2_avatar_69.99"
            )
            .onTapGesture {
                selectedSubscriptionID = "2_avatar_69.99"
            }
            .padding(.bottom)
            
            Button {
                Task {
                    await handleContinueTap()
                }
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
            .padding(.bottom, 24)
            
            PaywallBottomLegalButtons(withRestoreButton: false) { action in
                switch action {
                    
                case .terms:
                    webTitle = "Terms of Use"
                    webURL = URL(string: "https://docs.google.com/document/d/1sM80Feufp8jTebygWDq-rj00Ju19fRSkI9GWaodUeRA/edit?usp=sharing")
                    withAnimation { showWebView = true }
                case .restore:
                    print("Should restore")
                case .privacy:
                    webTitle = "Privacy Policy"
                    webURL = URL(string: "https://docs.google.com/document/d/1l17QMMa0Hjz4ycyAGM9Qj_yIL-Zt-qSAqYW2qdHucW4/edit?usp=sharing")
                    withAnimation { showWebView = true }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)
        }
        .frame(height: 420)
        .background(Color.white)
        .padding(.horizontal)
        .fullScreenCover(isPresented: $showWebView) {
            if let webURL {
                SafariWebView(url: webURL)
            }
        }

    }
    
    private func handleContinueTap() async {
        guard let product = viewModel.subscriptions.first(where: { $0.productId == selectedSubscriptionID }) else {
            print("❌ Продукт не найден в Apphud Subscriptions")
            return
        }
        print("🟢 Покупаем: \(product.productId)")
        await viewModel.purchaseSubscription(product)
    }
}

#Preview {
    ZStack {
        
        Color.black101010
        AvatarPaywall() {
            
        }
        
    }
}
