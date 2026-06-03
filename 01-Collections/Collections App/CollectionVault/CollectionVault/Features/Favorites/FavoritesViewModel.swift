//
//  FavoritesViewModel.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

import Foundation

final class FavoritesViewModel {
    private let repository: CollectionRepositoryProtocol
    private let favoritesStore: FavoritesStore
    
    private(set) var favoriteItems: [(item: VaultItem, collectionName: String)] = []
    
    var onUpdate: (() -> Void)?
    
    init(repository: CollectionRepositoryProtocol, favoritesStore: FavoritesStore) {
        self.repository = repository
        self.favoritesStore = favoritesStore
    }
    
    func load() {
        let collections = repository.fetch()
        
        favoriteItems = collections.flatMap({ collection in
            let ids = collection.items.elements.map { $0.id }
            let favIds = favoritesStore.favorites(in: ids)
            
            return collection.items.elements
                .filter { favIds.contains($0.id) }
                .map { (item: $0, collectionName: collection.name) }
        })
        
        onUpdate?()
    }
    
    func toggleFavorite(for itemId: UUID) {
        favoritesStore.toggle(itemId)
        load()
    }
    
    func isFavorite(for itemId: UUID) -> Bool {
        favoritesStore.isFavorite(itemId)
    }
}
