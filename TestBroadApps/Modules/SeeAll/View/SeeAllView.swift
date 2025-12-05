//
//  SeeAllView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI
import ApphudSDK

struct SeeAllView: View {
    
    // MARK: - Public Properties
    
    @ObservedObject var viewModel: SeeAllViewModel
    let category: TemplateCategory
       
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: .zero) {
                HStack {
                    Image(.backIcon)
                        .resizable()
                        .frame(width: 48.fitW, height: 48.fitW)
                        .onTapGesture {
                            viewModel.pop()
                        }
                    
                    Spacer()
                    
                    Text(category.title ?? "Category")
                        .font(.interSemiBold(size: 18))
                        .foregroundStyle(.black101010)
                    
                    Spacer()

                    if !Apphud.hasPremiumAccess() {
                        Button {
                            viewModel.showPaywall = true
                        } label: {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.orangeF86B0D)
                                .frame(width: 44, height: 40)
                                .overlay {
                                    Image(.crownIcon)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.clear)
                            .frame(width: 44, height: 40)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                CategoryCollectionView(category: category) { item in
                    viewModel.effectTap(on: item)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $viewModel.showPaywall) {
            PaywallView()
        }
    }
}
