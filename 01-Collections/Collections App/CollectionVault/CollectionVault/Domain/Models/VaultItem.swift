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
    
    static func == (lhs: VaultItem, rhs: VaultItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
