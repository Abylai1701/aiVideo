//
//  PaywallBottomLegalButtons.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 15.10.2025.
//

import SwiftUI

enum PaywallLegalButtonType: Hashable, CaseIterable {
    case terms
    case restore
    case privacy
}

struct PaywallBottomLegalButtons: View {
    
    // MARK: - Public Properties
    
    var withRestoreButton: Bool = true
    let action: (PaywallLegalButtonType) -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Button {
                action(.privacy)
            } label: {
                Text("Privacy Policy")
                    .font(.interMedium(size: 15))
                    .foregroundStyle(.black101010.opacity(0.6))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            if withRestoreButton {
                Button {
                    action(.restore)
                } label: {
                    Text("Recover")
                        .font(.interMedium(size: 15))
                        .foregroundStyle(.black101010)
                }
                .buttonStyle(.plain)
                
                Spacer()

            }
            
            Button {
                action(.terms)
            } label: {
                Text("Terms of Use")
                    .font(.interMedium(size: 15))
                    .foregroundStyle(.black101010.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
    }
}
