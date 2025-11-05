//
//  CustomTabBar.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import Foundation
import SwiftUI

enum Tab: Hashable {
    case chat
    case samples
    case history
    case settings
    
    var title: String {
        switch self {
        case .samples: "Samples"
        case .chat: "Chat"
        case .history: "History"
        case .settings: "Settings"
        }
    }
    
    var selectedIcon: ImageResource {
        switch self {
        case .samples: .samplesTab
        case .chat: .chatTab
        case .history: .historyTab
        case .settings: .settingsTab
        }
    }
    var unselectedIcon: ImageResource {
        switch self {
        case .samples: .samplesUnTab
        case .chat: .chatUnTab
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
                ForEach([Tab.chat, .samples, .history, .settings], id: \.self) { tab in
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
