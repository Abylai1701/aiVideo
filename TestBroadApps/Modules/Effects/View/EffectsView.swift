//
//  EffectsView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI

struct EffectsView: View {
    
    @ObservedObject var viewModel: EffectsViewModel

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if viewModel.categories.isEmpty {
                ProgressView()
                    .frame(width: 200, height: 200)
            } else {
                CategoriesView(categories: viewModel.categories) { item in
                    viewModel.seeAll(category: item)
                } ontapItem: { item in
                    viewModel.tapItem(item: item)
                }
                .padding(.top, 8)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showPaywall) {
            PaywallView()
        }
    }
}
