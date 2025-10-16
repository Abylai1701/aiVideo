//
//  MyFileManager.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//

import Foundation

final class MyFileManager {
    
    // MARK: - Private Properties
    
     let fileManager = FileManager()
    
    // MARK: - Public Methods
    
    func saveFile(with sourceURL: URL, to fileName: String) throws -> URL {
        let newFileName = fileName + "." + sourceURL.pathExtension
        let fileURL = try getDocumentsDirectoryURL().appendingPathComponent(newFileName)
        try fileManager.copyItem(at: sourceURL, to: fileURL)
        return fileURL
    }
    
    func removeFile(at fileURL: URL) throws {
        try fileManager.removeItem(at: fileURL)
    }
    
    func data(from url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }
    
    func getFileUrl(_ fileName: String) throws -> URL? {
        let files = try fileManager.contentsOfDirectory(at: .documentsDirectory, includingPropertiesForKeys: nil)
        for file in files where file.lastPathComponent.contains(fileName) {
            return file
        }
        return nil
    }
    
    func getDocumentsDirectoryURL() throws -> URL {
        return try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
    }
    
    func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
    
    func getCacheDirectoryURL() throws -> URL {
        return try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
    }
    
    func storeTemporaryFile(_ data: Data, withExtension ext: String) throws -> URL {
        let fileName = UUID().uuidString + "." + ext
        let fileURL = try getCacheDirectoryURL().appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        
        return fileURL
    }
}
