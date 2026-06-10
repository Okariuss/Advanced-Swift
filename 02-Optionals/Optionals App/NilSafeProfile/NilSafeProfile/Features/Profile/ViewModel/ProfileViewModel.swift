//
//  ProfileViewModel.swift
//  NilSafeProfile
//
//  Created by Okan Orkun on 9.06.2026.
//

import Foundation

@Observable
final class ProfileViewModel {
    var profile: UserProfile?
    var avatarURL: URL?
    var validatedSkills: [String] = []
    var errorMessage: String?
    var isLoading = false
    
    var alertTitle = ""
    var alertMessage = ""
    
    var toastMessage = ""
    
    private let service: ProfileService
    private let userId: String?
    
    init(service: ProfileService = ProfileService(), userId: String? = "usr_1234") {
        self.service = service
        self.userId = userId
    }
    
    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        // ── guard let shorthand ──
        guard let userId else {
            self.errorMessage = "Missing user ID."
            return
        }
        
        do {
            let fetchedProfile = try await service.fetchProfile(for: userId)
            self.profile = fetchedProfile
            
            // flatMap
            self.avatarURL = fetchedProfile.avatarPath.flatMap(URL.init(string:))
            
            // compactMap
            if let remoteSkills = fetchedProfile.rawSkills {
                self.validatedSkills = remoteSkills.compactMap { $0 }
            }
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // ── Optional Chaining Assignment ──
    func clearProfileNameOnlyIfProfileExists() {
        profile?.name = "Anonymous (Cleared)"
        
        self.toastMessage = "Optional Assignment Triggered: Name changed to Anonymous!"
    }
    
    // ── Short-Circuit Evaluation ──
    func getExpensiveSystemStatus() -> String {
        self.alertTitle = "🚨 Short-Circuit Warning"
        self.alertMessage = "This expensive method inside ?? operator was executed because the left side was NIL!"
        return "System Secure"
    }
    
    // ── for case let ──
    func triggerPatternMatchingData() {
        guard let raw = profile?.rawSkills else { return }
        
        var foundSkills: [String] = []
        
        for case let skill? in raw {
            foundSkills.append(skill)
        }
        
        self.alertTitle = "⚙️ Pattern Matching (for case let)"
        self.alertMessage = "Found \(foundSkills.count) valid skills out of \(raw.count) total array elements. Nils are ignored automatically:\n\n\(foundSkills.joined(separator: ", "))"
    }
    
    func clearToast() {
        self.toastMessage = ""
    }
}
