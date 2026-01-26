//
//  UpdateManager.swift
//  pomodoro
//
//  Manages automatic app updates using Sparkle framework
//

import Foundation
import Combine

#if canImport(Sparkle)
import Sparkle
#endif

@MainActor
class UpdateManager: ObservableObject {
    static let shared = UpdateManager()
    
    #if canImport(Sparkle)
    private let updaterController: SPUStandardUpdaterController?
    #endif
    
    @Published var canCheckForUpdates: Bool = false
    @Published var isUpdateAvailable: Bool = false
    
    private init() {
        #if canImport(Sparkle)
        // Initialize Sparkle updater
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        
        // Configure update check interval (daily)
        updaterController?.updater.updateCheckInterval = 86400 // 24 hours
        canCheckForUpdates = true
        #else
        // Sparkle not available - updates disabled
        canCheckForUpdates = false
        #endif
    }
    
    /// Check for updates manually
    func checkForUpdates() {
        #if canImport(Sparkle)
        updaterController?.checkForUpdates(nil)
        #else
        // Sparkle not available
        print("Sparkle framework not available. Please add Sparkle to enable automatic updates.")
        #endif
    }
    
    /// Get the current app version
    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    /// Get the current build number
    var currentBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// Get full version string
    var fullVersionString: String {
        "\(currentVersion) (build \(currentBuild))"
    }
}
