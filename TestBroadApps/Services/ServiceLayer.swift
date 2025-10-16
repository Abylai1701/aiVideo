//
//  ServiceLayer.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//


import Foundation

final class ServiceLayer {
    
    // MARK: - Services
    let network: NetworkService
    let templateManager: TemplateManager
    
    // MARK: - Init
    init() {
        self.network = NetworkService()
        self.templateManager = TemplateManager()
    }
    
    func initializeUserSession(id: String) async {
        if UserSessionManager.shared.userId != nil {
            print("✅ We have a token, id: \(String(describing: UserSessionManager.shared.userId))")
            print("✅ We have a token, token: \(String(describing: UserSessionManager.shared.accessToken))")
            do {
                try await authorizeUser(id: UserSessionManager.shared.userId!)
            } catch {
                print("❌ Failed to init user:", error)
            }
            return
        }

        
        do {
            let user = try await createUser(id: id)
            let auth = try await authorizeUser(id: user.id)
            UserSessionManager.shared.saveUser(id: user.id, token: auth.accessToken)
            print("✅ New User authorized, id: \(user.id)")
            print("✅ New User authorized, token: \(auth.accessToken)")
        } catch {
            print("❌ Failed to init user:", error)
        }
    }

    private func createUser(id: String) async throws -> UserResponse {
        let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/users")!
        let body = ["apphud_id": id]

        return try await network.postJSON(
            url: url,
            headers: ["accept": "application/json", "Content-Type": "application/json"],
            body: body
        )
    }

    @discardableResult
    private func authorizeUser(id: String) async throws -> AuthResponse {
        let url = URL(string: "https://aiphotoappfull.webberapp.shop/api/users/authorize")!
        let body = ["user_id": id]

        return try await network.postJSON(
            url: url,
            headers: ["accept": "application/json", "Content-Type": "application/json"],
            body: body
        )
    }
}
