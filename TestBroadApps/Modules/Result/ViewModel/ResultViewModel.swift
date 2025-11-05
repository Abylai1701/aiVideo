//
//  ResultViewModel.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 11.10.2025.
//

import Foundation
import UIKit
import Kingfisher

@MainActor
final class ResultViewModel: ObservableObject {
    
    @Published var result: String?
    @Published var showAlert: AlertType = .none

    private var router: Router
    
    init(result: String?, router: Router) {
        self.result = result
        self.router = router
    }
    
    func pop() {
        router.pop()
    }
    
    func loadUIImage() async -> UIImage? {
         guard let result, !result.isEmpty else { return nil }
         
         if result.starts(with: "http") {
             // 🌐 сетевой URL
             guard let url = URL(string: result) else { return nil }
             do {
                 let image = try await KingfisherManager.shared.retrieveImage(with: url).image
                 return image
             } catch {
                 print("❌ Failed to load from network:", error.localizedDescription)
                 return nil
             }
         } else {
             // 📁 локальный путь
             return UIImage(contentsOfFile: result)
         }
     }
     
     // MARK: - Download (Save to Photos)
     func download() async {
         guard let image = await loadUIImage() else {
             showAlert = .failed
             print("❌ No image to save")
             return
         }
         
         UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
         showAlert = .save
         print("✅ Image saved to Photos")
     }
     
     // MARK: - Download for Share
     func downloadImage() async -> UIImage? {
         await loadUIImage()
     }
}
