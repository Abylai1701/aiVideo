//
//  UIImage+Extensions.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 08.10.2025.
//

import Foundation
import UIKit

extension UIImage {
    func toJPEGData(compressionQuality: CGFloat = 0.8) -> Data? {
        if let data = self.jpegData(compressionQuality: compressionQuality) {
            return data
        } else if let cgImage = self.cgImage {
            return UIImage(cgImage: cgImage).jpegData(compressionQuality: compressionQuality)
        } else {
            return nil
        }
    }
    
    func saveToTemporaryDirectory(
        name: String = UUID().uuidString,
        compressionQuality: CGFloat = 0.9
    ) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(name).jpg")
        guard let data = jpegData(compressionQuality: compressionQuality) else {
            throw NSError(domain: "UIImage.saveToTemporaryDirectory", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create JPEG data"
            ])
        }
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }
    
}

extension Array where Element == UIImage {
    /// Сохраняет все изображения во временные файлы и возвращает массив URL
    func saveAllToTemporaryDirectory(
        compressionQuality: CGFloat = 0.9
    ) throws -> [URL] {
        try self.enumerated().map { index, image in
            try image.saveToTemporaryDirectory(name: "avatar_photo_\(index)", compressionQuality: compressionQuality)
        }
    }
}
