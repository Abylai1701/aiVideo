//
//  SubscriptionOptionView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 15.10.2025.
//

import SwiftUI

struct SubscriptionOptionView: View {
    var title: String
    var subtitle: String
    var price: String
    var discountText: String? = nil
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(.orangeF86B0D, lineWidth: 1)
                    .frame(width: 20, height: 20)
                if isSelected {
                    Circle()
                        .fill(.orangeF86B0D)
                        .frame(width: 12, height: 12)
                }
            }
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(title)
                    .font(.interMedium(size: 15))
                    .foregroundColor(.black101010)
                
                if discountText != nil {
                    Text(subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(.black101010.opacity(0.7))
                }
            }
            
            Spacer()
            if let text = discountText {
                Text(text)
                    .font(.interMedium(size: 15))
                    .foregroundColor(.black101010)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 2)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.orangeF86B0D, lineWidth: 1)
                    )
                    .padding(.trailing, 4)
            }
            Text(price)
                .font(.interSemiBold(size: 16))
                .foregroundColor(.black101010)
        }
        .padding(.vertical, (discountText != nil) ? 8 : 12)
        .padding(.horizontal, 12)
        .background(.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

