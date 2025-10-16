//
//  CategoryCollectionView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI

struct CategoryCollectionView: View {
    
    // MARK: - Public Properties
    
    let category: TemplateCategory
    var onTap: (Template) -> Void
    
    // MARK: - Private Properties
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible())
    ]
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8 ) {
                ForEach(category.templates) { item in
                    Button {
                        onTap(item)
                    } label: {
                        PhotoCard(item: item, forSeeAll: true)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}
