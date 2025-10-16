//
//  HistoryCard.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 11.10.2025.
//

import SwiftUI
import Kingfisher

struct HistoryCard: View {
    let item: GenerationResponse

    var body: some View {
        ZStack {
            KFImage(URL(string: item.result ?? ""))
                .setProcessor(
                    DownsamplingImageProcessor(size: CGSize(width: 210, height: 300))
                )
                .placeholder({
                    VStack(spacing: .zero) {
                        ProgressView()
                            .frame(width: 12, height: 12)
                            .tint(.white)
                            .background(
                                VisualEffectBlur(style: .systemThinMaterialDark)
                                    .clipShape(.circle)
                                    .frame(width: 32, height: 32)
                            )
                            .padding(.bottom, 10)
                            .padding(.top)
                        
                        Text("Wait for the generation to finish")
                            .font(.interMedium(size: 15))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                    }
                    .frame(width: 160)
                    .background(
                        VisualEffectBlur(style: .systemThinMaterialDark)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    )
                })
                .resizable()
                .scaledToFill()
        }
        .frame(
            width: 167.fitW,
            height: 240.fitW
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

