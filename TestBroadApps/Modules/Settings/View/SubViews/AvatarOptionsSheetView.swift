//
//  AvatarOptionsSheetView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//

import SwiftUI

struct AvatarOptionsSheetView: View {
    
    var rename: (String) -> Void
    var change: () -> Void
    var delete: () -> Void
    
    @State private var showRenameAlert = false
    @State private var newTitle = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.black101010.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
            VStack(spacing: 8) {
                Button {
                    showRenameAlert = true
                } label: {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.grayF5F5F5)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .overlay {
                            Text("Rename the avatar")
                                .font(.interMedium(size: 16))
                                .foregroundStyle(.black101010)
                        }
                }
                
                Button {
                    change()
                } label: {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.grayF5F5F5)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .overlay {
                            Text("Change the avatar photo")
                                .font(.interMedium(size: 16))
                                .foregroundStyle(.black101010)
                        }
                }
                Button {
                    delete()
                } label: {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.grayF5F5F5)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .overlay {
                            Text("Delete an avatar")
                                .font(.interMedium(size: 16))
                                .foregroundStyle(.black101010)
                        }
                }
                
            }
            Spacer()
        }
        .padding(.horizontal)
        .alert("Rename avatar", isPresented: $showRenameAlert) {
            TextField("Enter new name", text: $newTitle)
            Button("Cancel", role: .cancel) { newTitle = "" }
            Button("Save") {
                if !newTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                    rename(newTitle)
                    newTitle = ""
                }
            }
        } message: {
            Text("Enter a new name for your avatar")
        }
    }
}
