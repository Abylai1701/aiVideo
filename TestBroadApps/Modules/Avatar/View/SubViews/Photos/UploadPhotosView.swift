//
//  UploadPhotosView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 08.10.2025.
//

import SwiftUI

struct UploadPhotosView: View {
    
    @Binding var photos: [UIImage]
    @Binding var selectedImage: UIImage?
    @Namespace private var animation
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            
            VStack(spacing: .zero) {
                if photos.isEmpty {
                    Text("Upload from 10 to 50 photos")
                        .font(.interMedium(size: 16))
                        .foregroundStyle(.black101010.opacity(0.8))
                }
                
                if photos.isEmpty {
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(Array(photos.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 167.fitW, height: 167.fitW)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                selectedImage = image
                                            }
                                        }
                                    Button {
                                        photos.remove(at: index)
                                    } label: {
                                        Circle()
                                            .fill(.clear)
                                            .background(VisualEffectBlur(style: .systemThinMaterialDark))
                                            .frame(width: 24, height: 24)
                                            .overlay {
                                                Image(.littleCloseIcon)
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                            }
                                            .clipShape(Circle())
                                            .padding(4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
                
                Spacer(minLength: 14.fitH)
            }
        }
    }
}


#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(router: Router()))
}
