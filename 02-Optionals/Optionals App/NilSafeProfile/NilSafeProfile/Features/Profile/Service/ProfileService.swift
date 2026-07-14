//
//  ProfileService.swift
//  NilSafeProfile
//
//  Created by Okan Orkun on 9.06.2026.
//

import Foundation

// This service is inside the Profile feature because it only fetches profile data
final class ProfileService {
    func fetchProfile(for userId: String) async throws -> UserProfile {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return UserProfile(
            name: "Okan",
            email: nil, // Missing field from backend
            phone: "+90 555 123 45 67",
            age: 29,
            avatarPath: "https://picsum.photos/200",
            company: Company(name: "Apple", department: nil),
            rawSkills: ["Swift", nil, "iOS", nil, "SwiftUI"] // API sends nil values inside the array
        )
    }
}
