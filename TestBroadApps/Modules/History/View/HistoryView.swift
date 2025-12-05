//
//  HistoryView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 11.10.2025.
//

import SwiftUI

struct HistoryView: View {
    
    @ObservedObject var viewModel: HistoryViewModel
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: .zero) {
                HStack {
                    Text("History")
                        .font(.interSemiBold(size: 22))
                        .foregroundStyle(.black101010)
                    
                    Spacer(minLength: 0)
                    
                    HStack(spacing: 4) {
                        Image(.generateIcon)
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("\(viewModel.tokensCount)")
                            .font(.interMedium(size: 16))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.orangeF86B0D)
                    )
                    
                }
                .padding(.horizontal)
                .padding(.bottom)
                .padding(.top)
                
                if viewModel.history.isEmpty && viewModel.isLoading {
                    ProgressView()
                        .tint(.black)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.history.isEmpty {
                    HistoryEmptyView {
                        viewModel.effectsTap()
                    }
                    .padding(.bottom, 100)
                } else {
                    HistoryCollectionView(
                        items: viewModel.history,
                        onTap: { item in
                            viewModel.effectTap(on: item)
                        },
                        onItemWillAppear: { item in
                            if item.id == viewModel.history.last?.id {
                                Task { await viewModel.loadHistory() }
                            }
                        }
                    )
                    .refreshable {
                        await viewModel.loadHistory(reset: true)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.fetchUserInfo()
            }
        }
    }
}
