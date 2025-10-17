//
//  MyApp.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI
import AppTrackingTransparency
import AdSupport
import ApphudSDK

@main
struct MyApp: App {
    
    private let services = ServiceLayer()
    @Environment(\.scenePhase) var scenePhase

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
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        ATTrackingManager.requestTrackingAuthorization { status in
                            switch status {
                            case .authorized:
                                let idfa = ASIdentifierManager.shared().advertisingIdentifier
                                Apphud.setDeviceIdentifiers(idfa: idfa.uuidString, idfv: UIDevice.current.identifierForVendor?.uuidString)
                            case .denied, .restricted, .notDetermined:
                                print("IDFA authorization not granted")
                            @unknown default:
                                break
                            }
                        }
                    }
                }
            
        }
    }
}
