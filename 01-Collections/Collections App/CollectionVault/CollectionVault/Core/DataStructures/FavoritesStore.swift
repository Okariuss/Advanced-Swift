//
//  FavoritesStore.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

final class FavoritesStore {
    
    private var storage = Set<UUID>()

    init() {}    
    
    func toggle(_ id: UUID) {
        if storage.contains(id) {
            storage.remove(id)
        } else {
            storage.insert(id)
        }
    }
    
    func isFavorite(_ id: UUID) -> Bool {
        storage.contains(id)
    }
    
    func favorites(in ids: [UUID]) -> Set<UUID> {
        storage.intersection(ids)
    }
}
