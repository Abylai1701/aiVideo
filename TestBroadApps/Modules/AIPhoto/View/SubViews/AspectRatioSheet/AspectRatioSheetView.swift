//
//  AspectRatioSheetView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 09.10.2025.
//

import SwiftUI

struct AspectRatioSheetView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAspect: AspectRatioType
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.black101010.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(AspectRatioType.allCases, id: \.self) { ratio in
                        Button {
                            selectedAspect = ratio
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(ratio.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                
                                Text(ratio.value)
                                    .font(.interMedium(size: 15))
                                    .foregroundStyle(.black101010)
                                    
                            }
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.grayF5F5F5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollDisabled(true)
        }
        .frame(height: 266)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 40))
    }
}
