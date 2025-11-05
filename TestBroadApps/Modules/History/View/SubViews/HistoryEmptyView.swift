//
//  HistoryEmptyView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 11.10.2025.
//

import SwiftUI

struct HistoryEmptyView: View {
    
    var tapToEffects: () -> Void
    
    var body: some View {
        VStack(spacing: .zero) {
            ZStack {
                Color.grayF5F5F5
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.bottom)
        .overlay {
            VStack(alignment: .center, spacing: .zero) {
                Image(.orangeStarsIcon)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.bottom, 40)
                
                Text("It's empty now")
                    .font(.interSemiBold(size: 22))
                    .foregroundStyle(.black101010)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)

                Button {
                    tapToEffects()
                } label: {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.orangeF86B0D)
                        .frame(width: 240.fitW, height: 44.fitW)
                        .overlay {
                            Text("To the generations")
                                .font(.interMedium(size: 16))
                                .foregroundStyle(.white)
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    HistoryEmptyView() {
        
    }
}
