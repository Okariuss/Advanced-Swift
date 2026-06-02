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
    
    var isFavorite: Bool {
        FavoritesStore.shared.isFavorite(id)
    }
}
