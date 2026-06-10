//
//  UserProfile.swift
//  NilSafeProfile
//
//  Created by Okan Orkun on 9.06.2026.
//

import Foundation

// MARK: - Models
struct UserProfile: Codable {
    var name: String? // Use 'var' to demonstrate local assignment modifications
    let email: String?
    let phone: String?
    let age: Int?
    let avatarPath: String?
    let company: Company?
    let rawSkills: [String?]?
}

struct Company: Codable {
    let name: String?
    let department: String?
}
