//
//  TokenPaywall.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 16.10.2025.
//

import SwiftUI

struct TokenPaywall: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel = PurchaseManager.shared
    var onSuccess: () -> Void
    
    @State private var showPolicy = false
    @State private var showTerms = false
    
    @State private var selectedSubscriptionID: String = "2000_Tokens_99.99"
    
    
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            Capsule()
                .fill(Color.black101010.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            Text("Get more tokens")
                .font(.interSemiBold(size: 22))
                .foregroundStyle(.black101010)
                .padding(.bottom, 12)
            
            Text("Top up your balance to generate more images")
                .font(.interMedium(size: 16))
                .foregroundStyle(.black101010.opacity(0.7))
                .padding(.bottom, 24)
  
            SubscriptionOptionView(
                title: "2 000 tokens",
                subtitle: "2 000 images",
                price: "$99.99",
                discountText: "Save 80%",
                isSelected: selectedSubscriptionID == "2000_Tokens_99.99"
            )
            .onTapGesture {
                selectedSubscriptionID = "2000_Tokens_99.99"
            }
            .padding(.bottom, 8)
            
            SubscriptionOptionView(
                title: "1 000 tokens",
                subtitle: "1 000 images",
                price: "$59.99",
                discountText: "Save 60%",
                isSelected: selectedSubscriptionID == "1000_Tokens_59.99"
            )
            .onTapGesture {
                selectedSubscriptionID = "1000_Tokens_59.99"
            }
            .padding(.bottom, 8)
            
            SubscriptionOptionView(
                title: "500 tokens",
                subtitle: "500 images",
                price: "$34.99",
                discountText: "Save 40%",
                isSelected: selectedSubscriptionID == "500_Tokens_34.99"
            )
            .onTapGesture {
                selectedSubscriptionID = "500_Tokens_34.99"
            }
            .padding(.bottom, 8)
            
            SubscriptionOptionView(
                title: "250 tokens",
                subtitle: "250 images",
                price: "$19.99",
                isSelected: selectedSubscriptionID == "250_Tokens_19.99"
            )
            .onTapGesture {
                selectedSubscriptionID = "250_Tokens_19.99"
            }
            .padding(.bottom, 8)
            
            SubscriptionOptionView(
                title: "100 tokens",
                subtitle: "100 images",
                price: "$9.99",
                isSelected: selectedSubscriptionID == "100_Tokens_9.99"
            )
            .onTapGesture {
                selectedSubscriptionID = "100_Tokens_9.99"
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
                    showTerms = true
                case .restore:
                    Task { await viewModel.restore() }
                case .privacy:
                    showPolicy = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)
        }
        .frame(height: 510)
        .background(Color.white)
        .padding(.horizontal)
        .safari(urlString: "https://docs.google.com/document/d/1l17QMMa0Hjz4ycyAGM9Qj_yIL-Zt-qSAqYW2qdHucW4/edit?usp=sharing", isPresented: $showPolicy)
        .safari(urlString: "https://docs.google.com/document/d/1sM80Feufp8jTebygWDq-rj00Ju19fRSkI9GWaodUeRA/edit?usp=sharing", isPresented: $showTerms)
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
