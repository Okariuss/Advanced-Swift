//
//  VaultItem.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

struct VaultItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var createdAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case createdAt
    }
}
