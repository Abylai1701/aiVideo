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
    
    func download() async {
        guard let urlString = result, let url = URL(string: urlString) else {
            print("❌ Invalid image URL")
            return
        }
        
        do {
            let image = try await KingfisherManager.shared.retrieveImage(with: url).image
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print("✅ Image saved to Photos")
            showAlert = .save
            
        } catch {
            print("❌ Failed to download image:", error.localizedDescription)
            showAlert = .failed

        }
    }
    
    func downloadImage() async -> UIImage? {
        guard let urlString = result,
              let url = URL(string: urlString) else { return nil }
        do {
            let image = try await KingfisherManager.shared.retrieveImage(with: url).image
            return image
        } catch {
            print("❌ Failed to get image for share:", error.localizedDescription)
            return nil
        }
    }
}
