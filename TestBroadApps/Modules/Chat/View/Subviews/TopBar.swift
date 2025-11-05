//
//  TopBar.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 03.11.2025.
//

import SwiftUI

struct TopBar: View {
    let title: String
    let badge: String
    var onMenu: () -> Void
    var onFilters: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onMenu) {
                Image(.showSideTableIcon)
                    .resizable()
                    .frame(width: 48, height: 48)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.interMedium(size: 18))
                    .foregroundStyle(.black101010)

                HStack(spacing: 4) {
                    Image(.littleStarsIcon)
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text(badge)
                        .font(.interMedium(size: 16))
                        .foregroundStyle(.black101010.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onFilters) {
                Image(.showFiltersIcon)
                    .resizable()
                    .frame(width: 48, height: 48)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.white)
    }
}
