import SwiftUI

struct SelectTypeOfAddingSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var gallerySelect: () -> Void
    var cameraSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.black101010.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
            VStack(spacing: 8) {
                Button {
                    gallerySelect()
                    dismiss()
                } label: {
                    Text("Add from Gallery")
                        .font(.interMedium(size: 16))
                        .foregroundStyle(.black101010)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.grayF5F5F5)
                        )
                }
                .buttonStyle(.plain)
                
                Button {
                    cameraSelect()
                    dismiss()
                } label: {
                    Text("Add from Camera")
                        .font(.interMedium(size: 16))
                        .foregroundStyle(.black101010)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.grayF5F5F5)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(height: 180)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 40))
    }
}
