//
//  PhotoCard.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI
import Kingfisher

struct PhotoCard: View {
    let item: Template
    var forSeeAll: Bool = false

    var body: some View {
        ZStack {
            if let preview = item.preview {
                KFImage(URL(string: preview))
                    .setProcessor(
                        DownsamplingImageProcessor(size: CGSize(width: 210, height: 300))
                    )
                    .placeholder({
                        ProgressView()
                            .frame(width: 60, height: 60)
                    })
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .bottomLeading) {
                        Text(item.title ?? "")
                            .font(.interSemiBold(size: 16))
                            .foregroundStyle(.white)
                            .padding(12)
                    }
            }
        }
        .frame(
            width: forSeeAll ? 167.fitW : 140.fitW,
            height: forSeeAll ? 240.fitW : 200.fitW
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
