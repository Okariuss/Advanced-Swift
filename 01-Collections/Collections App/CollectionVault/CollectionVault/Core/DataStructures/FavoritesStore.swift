//
//  FavoritesStore.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

protocol FavoritesStoreProtocol: AnyObject {
    func toggle(_ id: UUID)
    func isFavorite(_ id: UUID) -> Bool
    func favorites(in ids: [UUID]) -> Set<UUID>
}

protocol FavoritesPersistence {
    func load() -> Set<UUID>
    func save(_ ids: Set<UUID>)
}

final class UserDefaultsFavoritesPersistence: FavoritesPersistence {
    private let key = "cv_favorites_store"
    
    func load() -> Set<UUID> {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data)
        else { return [] }
        return decoded
    }
    
    func save(_ ids: Set<UUID>) {
        guard let data = try? JSONEncoder().encode(ids) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

final class FavoritesStore: FavoritesStoreProtocol {
    
    private let persistence: FavoritesPersistence
    private var storage: Set<UUID>
    
    init(persistence: FavoritesPersistence = UserDefaultsFavoritesPersistence()) {
        self.persistence = persistence
        self.storage = persistence.load()
    }
    
    func toggle(_ id: UUID) {
        if storage.contains(id) {
            storage.remove(id)
        } else {
            storage.insert(id)
        }
        persistence.save(storage)
    }
    
    func isFavorite(_ id: UUID) -> Bool {
        storage.contains(id)
    }
    
    func favorites(in ids: [UUID]) -> Set<UUID> {
        storage.intersection(Set(ids))
    }
}
