//
//  TemplateManager.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//


import Foundation

final class TemplateManager {

    // MARK: - Public Published
    @Published private(set) var templates: [TemplateCategory] = []

    // MARK: - Private Properties
    private let fileName = "templates_cache.json"
    private let decoder = JSONDecoder()
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    private let network = NetworkService()

    // MARK: - Public Methods

    /// Загружает шаблоны: сначала из кэша, затем из сети
    
    func prepareTemplates() async {
        if let cached = loadTemplates() {
            await MainActor.run {
                templates = cached
            }
            // обновим сеть фоном
            Task.detached(priority: .background) {
                await self.updateTemplatesInBackground()
            }
            return
        }

        await updateTemplatesInBackground()
    }

    private func updateTemplatesInBackground() async {
        do {
            let fresh = try await fetchTemplates()
            try saveTemplates(fresh)
            await MainActor.run {
                self.templates = fresh
            }
        } catch {
            print("⚠️ Failed to update templates:", error)
        }
    }
    func getTemplates() -> [TemplateCategory] {
        templates.filter { category in
            return !category.templates.isEmpty
        }
    }

    func getTemplatePreview(path: String) async throws -> URL {
        let destination = try getDocumentsDirectory().appendingPathComponent(path)
        if FileManager.default.fileExists(atPath: destination.path) {
            return destination
        }
        return try await network.download(
            url: URL(string: path)!,
            to: destination
        )
    }

    // MARK: - Private Methods

    private func fetchTemplates() async throws -> [TemplateCategory] {
        let urlString = "https://aiphotoappfull.webberapp.shop/api/generations/fotobudka/image-templates?lang=en&gender=f&showAll=false"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        return try await network.get(url: url, headers: ["accept": "application/json"])
    }

    private func saveTemplates(_ templates: [TemplateCategory]) throws {
        let data = try encoder.encode(templates)
        let url = try getDocumentsDirectory().appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
    }

    private func loadTemplates() -> [TemplateCategory]? {
        guard let url = try? getDocumentsDirectory().appendingPathComponent(fileName),
              FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let decoded = try? decoder.decode([TemplateCategory].self, from: data)
        else {
            return nil
        }
        return decoded
    }

    private func preloadPreviews(for categories: [TemplateCategory]) async throws {
        let allTemplates = categories.flatMap(\.templates)
        let urls = allTemplates.compactMap(\.preview)

        try await withThrowingTaskGroup(of: Void.self) { group in
            for urlString in Set(urls) {
                group.addTask { [self] in
                    guard let url = URL(string: urlString) else { return }
                    try await downloadPreviewIfNeeded(url: url)
                }
            }
            try await group.waitForAll()
        }
    }

    private func downloadPreviewIfNeeded(url: URL) async throws {
        let fileName = url.lastPathComponent
        let destination = try getDocumentsDirectory().appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: destination.path) { return }
        _ = try await network.download(url: url, to: destination)
    }

    private func getDocumentsDirectory() throws -> URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw URLError(.cannotFindHost)
        }
        return url
    }
}
