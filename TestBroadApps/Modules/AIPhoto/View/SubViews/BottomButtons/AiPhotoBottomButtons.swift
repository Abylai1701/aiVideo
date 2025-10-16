//
//  AiPhotoBottomButtons.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 09.10.2025.
//

import SwiftUI

enum AspectRatioType: CaseIterable {
    case four_three
    case sixteen_nine
    case nine_sixteen
    case three_two
    case one_one
    
    var value: String {
        switch self {
        case .four_three: "4:3"
        case .sixteen_nine: "16:9"
        case .nine_sixteen: "9:16"
        case .three_two: "3:2"
        case .one_one: "1:1"
        }
    }
    
    var image: ImageResource {
        switch self {
        case .four_three:
                ._4_3
        case .sixteen_nine:
                ._16_9
        case .nine_sixteen:
                ._9_16
        case .three_two:
                ._3_2
        case .one_one:
                ._1_1
        }
    }
}
struct AiPhotoBottomButtons: View {
    @Binding var aspectRatio: AspectRatioType
    @Binding var prompt: String
    
    var onAspectRatioTap: () -> Void
    var onAvatarTap: () -> Void
    var onGenerateTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Button {
                    onAspectRatioTap()
                } label: {
                    HStack(spacing: 4) {
                        Image(aspectRatio.image)
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text(aspectRatio.value)
                            .font(.interMedium(size: 15))
                            .foregroundColor(.black101010)
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color.grayF5F5F5)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                
                Button {
                    onAvatarTap()
                } label: {
                    HStack(spacing: 4) {
                        Image(.avatarIcon)
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        Text("Avatar")
                            .font(.interMedium(size: 15))
                            .foregroundColor(.black101010)
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color.grayF5F5F5)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $prompt)
                    .font(.interMedium(size: 15))
                    .foregroundColor(.black101010)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .scrollContentBackground(.hidden)
                    .background(Color.grayF5F5F5)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .frame(height: 108)
                
                if prompt.isEmpty {
                    Text("Describe your dream photo — e.g., ‘A cat astronaut on Mars wearing a gold spacesuit’")
                        .font(.interMedium(size: 15))
                        .foregroundColor(.black101010.opacity(0.2))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                }
            }
            
            Button {
                onGenerateTap()
            } label: {
                RoundedRectangle(cornerRadius: 24)
                    .fill(prompt.isEmpty ? Color.orangeF86B0D.opacity(0.5) : Color.orangeF86B0D)
                    .frame(height: 44.fitH)
                    .overlay {
                        HStack {
                            Image(.generateIcon)
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text("Generate")
                                .font(.interMedium(size: 16))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.bottom)
            }
            .disabled(prompt.isEmpty)
        }
        .padding(.horizontal)
    }
}
#Preview {
    AiPhotoBottomButtons(aspectRatio: .constant(.four_three), prompt: .constant("")) {
        print("S")
    } onAvatarTap: {
        print("S")

    } onGenerateTap: {
        print("S")

    }
}
