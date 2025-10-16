//
//  SettingsToggleRow.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//

import SwiftUI

struct SettingsToggleRow: View {
    var icon: Image
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            icon
                .resizable()
                .frame(width: 20, height: 20)
            
            Text(title)
                .font(.interMedium(size: 16))
                .foregroundStyle(.black101010)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background(Color.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
