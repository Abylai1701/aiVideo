//
//  CustomTabBar.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import Foundation
import SwiftUI

enum Tab: Hashable {
    case effects
    case aiPhoto
    case history
    case settings
    
    var title: String {
        switch self {
        case .effects: "Effects"
        case .aiPhoto: "Ai photo"
        case .history: "History"
        case .settings: "Settings"
        }
    }
    
    var selectedIcon: ImageResource {
        switch self {
        case .effects: .effectsTab
        case .aiPhoto: .aiPhotoTab
        case .history: .historyTab
        case .settings: .settingsTab
        }
    }
    var unselectedIcon: ImageResource {
        switch self {
        case .effects: .effectsUnTab
        case .aiPhoto: .aiPhotoUnTab
        case .history: .historyUnTab
        case .settings: .settingsUnTab
        }
    }
}

struct CustomTabBar: View {
    @ObservedObject var router: Router

    var body: some View {
        VStack(spacing: .zero) {
            Rectangle()
                .frame(height: 1)
                .opacity(0.1)
            
            HStack {
                ForEach([Tab.effects, .aiPhoto, .history, .settings], id: \.self) { tab in
                    Spacer()
                    VStack(spacing: 8) {
                        Image(router.selectedTab == tab ? tab.unselectedIcon : tab.selectedIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                        Text(tab.title)
                            .font(.interMedium(size: 15))
                            .foregroundColor(router.selectedTab == tab ? .orangeF86B0D : .gray)
                    }
                    .padding(.vertical, 6)
                    .padding(.top, 6)
                    .onTapGesture {
                        router.selectedTab = tab
                    }
                    Spacer()
                }
            }
        }
        .background(.white)
    }
}
