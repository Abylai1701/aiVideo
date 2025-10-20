//
//  RateAppView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 13.10.2025.
//

import SwiftUI
import StoreKit

struct RateAppView: View {
    
    @ObservedObject var router: Router
    
    var body: some View {
        VStack(spacing: .zero) {
            Spacer(minLength: 40)

            Image(.bigHeartIcon)
                .resizable()
                .frame(maxWidth: 240.fitW, maxHeight: 240.fitW)
                .padding(.bottom, 12)

            VStack(spacing: .zero) {
                Text("Would you like to rate our app?")
                    .font(.interSemiBold(size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.orangeF86B0D)
                    .padding(.bottom)
                
                Text("Please rate our app so we can improve it for you and make it even cooler.")
                    .font(.interMedium(size: 16))
                    .foregroundStyle(.black101010.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 45.fitW)
            
            HStack(spacing: 4) {
                HStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.grayF5F5F5)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .overlay {
                    Text("Later")
                        .font(.interMedium(size: 15))
                        .foregroundStyle(.black101010)
                }
                .onTapGesture {
                    router.pop()
                }
         
                HStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.orangeF86B0D)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .overlay {
                    Text("Rate now")
                        .font(.interMedium(size: 16))
                        .foregroundStyle(.white)
                }
                .onTapGesture {
                    requestReviewOrOpenStore()
                }
                
            }
            .padding(.horizontal)

            Spacer()
        }
        .overlay(alignment: .top) {
            headerSecond
        }
        .navigationBarHidden(true)
    }
    
    private var headerSecond: some View {
        HStack {
            Image(.backIcon)
                .resizable()
                .frame(width: 48.fitW, height: 48.fitW)
                .onTapGesture {
                    router.pop()
                }
                       
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .overlay(alignment: .center) {
            Text("Rate us")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(.black101010)
        }
    }
    
    func requestReviewOrOpenStore() {
         if let scene = UIApplication.shared.connectedScenes
             .compactMap({ $0 as? UIWindowScene })
             .first(where: { $0.activationState == .foregroundActive }) {
             SKStoreReviewController.requestReview(in: scene)
         }
     }
}
