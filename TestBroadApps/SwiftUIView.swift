//
//  SwiftUIView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        ZStack {
            Color.white
            
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .foregroundStyle(.black)
                
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SwiftUIView()
}
