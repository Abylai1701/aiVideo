//
//  PaywallView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 15.10.2025.
//

import SwiftUI
import WebKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var viewModel = PurchaseManager.shared

    @State private var offset: CGFloat = 0
    @State private var animationActive = true
    @State private var selectedSubscriptionID: String = "yearly_39.99_nottrial"

    @State private var showPolicy = false
    @State private var showTerms = false
    
    private let images: [ImageResource] = [.pw1, .pw2, .pw3, .pw4]
    
    var body: some View {
        ZStack(alignment: .top) {

            Image(.human)
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: 600.fitH)
                .ignoresSafeArea()
            
            VStack {
                Spacer(minLength: 0)
                Spacer(minLength: 0)
                Spacer(minLength: 0)
                Spacer(minLength: 0)
                Spacer(minLength: 0)
                     
                Spacer(minLength: 10)
                
                VStack {
                    Image(.text)
                        .resizable()
                        .frame(width: 276.fitW, height: 114.fitH)
                }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .bottomLeading) {
                    Image(.genIcon)
                        .resizable()
                        .frame(width: 18, height: 18)
                        .padding(.leading, 13.fitW)
                        .offset(y: -10)
                }
                .overlay(alignment: .topTrailing) {
                    Image(.genIcon)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(.trailing, 6.fitW)
                        .offset(y: 10)
                }
                
                Spacer(minLength: 0)

                
                bottomButtonFirst
            }
            .ignoresSafeArea()
        }
        .overlay(alignment: .top) {
            header
        }
        .safari(urlString: "https://docs.google.com/document/d/1l17QMMa0Hjz4ycyAGM9Qj_yIL-Zt-qSAqYW2qdHucW4/edit?usp=sharing", isPresented: $showPolicy)
        .safari(urlString: "https://docs.google.com/document/d/1sM80Feufp8jTebygWDq-rj00Ju19fRSkI9GWaodUeRA/edit?usp=sharing", isPresented: $showTerms)
        .alert(item: $viewModel.alert) { alert in
            if alert.message == "Purchase success" {
                 return Alert(
                     title: Text("Purchase success"),
                     message: Text(""),
                     dismissButton: .default(Text("OK")) {
                         dismiss()
                     }
                 )
             } else {
                 return Alert(
                     title: Text("Purchase failed"),
                     message: Text(alert.message),
                     dismissButton: .default(Text("OK")) {
                         viewModel.alert = nil
                     }
                 )
             }
        }
    }
    
    private var header: some View {
        HStack {
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(.littleCloseIcon)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)

        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    func startInfiniteScroll(totalWidth: CGFloat) {
        Task {
            while animationActive {
                withAnimation(.linear(duration: 15)) {
                    offset -= totalWidth
                }
                try? await Task.sleep(for: .seconds(15))
                offset = 0
            }
        }
    }
    private var bottomButtonFirst: some View {
        VStack(alignment: .center, spacing: .zero) {
            SubscriptionOptionView(
                title: "Weekly",
                subtitle: "",
                price: "$6.99",
                isSelected: selectedSubscriptionID == "week_6.99_nottrial"
            )
            .onTapGesture {
                selectedSubscriptionID = "week_6.99_nottrial"
            }
            .padding(.bottom, 8)
            
            SubscriptionOptionView(
                title: "Yearly",
                subtitle: "$3 per month",
                price: "$39.99",
                discountText: "Save 60%",
                isSelected: selectedSubscriptionID == "yearly_39.99_nottrial"
            )
            .onTapGesture {
                selectedSubscriptionID = "yearly_39.99_nottrial"
            }
            .padding(.bottom, 20)
            
            
            HStack(alignment: .center, spacing: 8) {
                Image(.clockIcon)
                    .resizable()
                    .frame(width: 16, height: 16)
                
                Text("Сancel at any time")
                    .font(.system(size: 15))
                    .foregroundStyle(.black101010.opacity(0.7))
            }
            .padding(.bottom, 20)
            
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
            
            PaywallBottomLegalButtons { action in
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
        }
        .padding(.horizontal)
        .padding(.top)
        .padding(.bottom, 34)
        .background(.white)
        .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
    }
    
    
    // MARK: - Continue Logic
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
    PaywallView()
}
