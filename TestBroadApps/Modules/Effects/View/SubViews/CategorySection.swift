//
//  CategorySection.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI

struct CategorySection: View {
    let category: TemplateCategory
    var onTap: (TemplateCategory) -> Void
    var onTapItem: (Template) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.fitH) {
            HStack {
                Text(category.title ?? "Category")
                    .font(.interSemiBold(size: 22))
                    .foregroundColor(.black101010)
                
                Spacer()
                
                Image(.arrowRight)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap(category)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) { // FIX
                    ForEach(category.templates.prefix(5)) { item in
                        PhotoCard(item: item)
                            .onTapGesture {
                                onTapItem(item)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
