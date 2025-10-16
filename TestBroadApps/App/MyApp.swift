//
//  MyApp.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI

@main
struct MyApp: App {
    
    private let services = ServiceLayer()
    
    init() {
        NotificationService.shared.configure()
        ApphudUserManager.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(services: services)
                .preferredColorScheme(.light)
                .onAppear {
                    AppConfigurator.configureKingfisher()
                    
                    if let id = ApphudUserManager.shared.getUserID() {
                        Task {
                            await services.initializeUserSession(id: id)
                        }
                    } else {
                        Task {
                            await services.initializeUserSession(id: UUID().uuidString)
                        }
                    }
                }
        }
    }
}
