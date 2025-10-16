//
//  AvatarResult.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 08.10.2025.
//

import SwiftUI
import Kingfisher

struct AvatarResult: View {
    var url: URL?
    
    var body: some View {
        ZStack {
            KFImage(url)
                .resizable()
                .padding(.horizontal)
                .padding(.bottom)
        }
    }
}

#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(router: Router()))
}
