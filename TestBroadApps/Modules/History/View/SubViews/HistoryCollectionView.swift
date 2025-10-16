//
//  HistoryCollectionView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 11.10.2025.
//

import SwiftUI

struct HistoryCollectionView: View {
    
    // MARK: - Public Properties
    
    let items: [GenerationResponse]
    var onTap: (GenerationResponse) -> Void
    var onItemWillAppear: ((GenerationResponse) -> Void)? = nil

    // MARK: - Private Properties
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible())
    ]
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8 ) {
                ForEach(items, id: \.id ) { item in
                    Button {
                        if item.result != nil {
                            onTap(item)
                        }
                    } label: {
                        HistoryCard(item: item)
                            .onAppear {
                                onItemWillAppear?(item)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }
}
