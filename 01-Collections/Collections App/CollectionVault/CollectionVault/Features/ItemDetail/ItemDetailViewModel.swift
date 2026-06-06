//
//  ItemDetailViewModel.swift
//  CollectionVault
//
//  Created by Okan Orkun on 4.06.2026.
//

import Foundation

final class ItemDetailViewModel {

    private let repository: CollectionRepositoryProtocol
    private let collectionId: UUID
    private let favoritesStore: FavoritesStoreProtocol
    
    private weak var coordinator: ItemDetailNavigationDelegate?

    private(set) var item: VaultItem
    private(set) var collectionName: String

    var onUpdate: (() -> Void)?

    init(
        item: VaultItem,
        collectionName: String,
        collectionId: UUID,
        repository: CollectionRepositoryProtocol,
        favoritesStore: FavoritesStoreProtocol,
        coordinator: ItemDetailNavigationDelegate
    ) {
        self.item = item
        self.collectionName = collectionName
        self.collectionId = collectionId
        self.repository = repository
        self.favoritesStore = favoritesStore
        self.coordinator = coordinator
    }

    var title: String {
        item.title
    }

    var createdDateText: String {
        item.createdAt.formatted(
            date: .long,
            time: .shortened
        )
    }

    var isFavorite: Bool {
        favoritesStore.isFavorite(item.id)
    }

    func toggleFavorite() {
        favoritesStore.toggle(item.id)
        onUpdate?()
    }

    func renameItem(newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var updated = item
        updated.title = trimmed

        repository.updateItem(updated, in: collectionId)

        item = updated
        onUpdate?()
    }

    func deleteItem() {
        repository.deleteItem(item.id, in: collectionId)
        coordinator?.didDeleteItem()
    }
}
