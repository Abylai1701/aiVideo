import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    @Binding var selectedImages: [ChatImage]
    var onSend: () -> Void
    var selectType: () -> Void
    
    private var isEnabled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedImages.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 6) {
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedImages) { image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay {
                                        if image.isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        }
                                    }
                                Button {
                                    withAnimation {
                                        selectedImages.removeAll { $0.id == image.id }
                                    }
                                } label: {
                                    Image(.miniCloseIcon)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                                .padding(4)
                            }
                        }
                    }
                    .padding(8)
                }
            }
            
            HStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("Start typing a prompt")
                            .foregroundStyle(Color.gray.opacity(0.6))
                    }
                    TextField("", text: $text, axis: .vertical)
                        .font(.interMedium(size: 15))
                        .foregroundStyle(.black101010)
                        .lineLimit(1...3)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(false)
                }
                
                Button { selectType() } label: {
                    Image(.addImageIcon)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                
                Button {
                    if isEnabled {
                        onSend()
                    }
                } label: {
                    Image(.sendIcon)
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled)
            }
            .padding(.leading, 20)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: !selectedImages.isEmpty ? 24 : 48)
                .fill(Color.white)
                .strokeBorder(Color.grayF5F5F5, lineWidth: 1.5)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedImages)
    }
}

struct ChatImage: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
    var isLoading: Bool = false
}
