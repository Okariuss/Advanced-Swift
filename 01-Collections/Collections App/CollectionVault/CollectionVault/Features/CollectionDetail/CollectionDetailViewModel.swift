//
//  CollectionDetailViewModel.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

import Foundation

final class CollectionDetailViewModel {
    private let repository: CollectionRepositoryProtocol
    private let collectionId: UUID
    private let duplicateService = DuplicateService()
    private let favoritesStore: FavoritesStore
    
    private(set) var collection: Collection?
    private(set) var duplicates: [String: Int] = [:]
    private(set) var duplicateLabels: [String: String] = [:]
    
    private var allCollections: [Collection] = []
    
    var onUpdate: (() -> Void)?
    
    init(repository: CollectionRepositoryProtocol, collectionId: UUID, favoritesStore: FavoritesStore = FavoritesStore()) {
        self.repository = repository
        self.collectionId = collectionId
        self.favoritesStore = favoritesStore
    }
    
    func load() {
        allCollections = repository.fetch()
        collection = allCollections.first(where: { $0.id == collectionId })
        refreshDuplicates()
        onUpdate?()
    }
    
    func addItem(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmed.isEmpty,
            let index = collectionIndex()
        else {
            return
        }
        
        let newItem = VaultItem(id: UUID(), title: trimmed, createdAt: Date())
        allCollections[index].items.insert(newItem)
        
        repository.save(allCollections)
        load()
    }
    
    func deleteItems(at offsets: IndexSet) {
        guard let index = collectionIndex() else { return }
        
        allCollections[index].items.remove(offsets)
        
        repository.save(allCollections)
        load()
    }
    
    func isFavorite(id: UUID) -> Bool {
        favoritesStore.isFavorite(id)
    }
    
    func toggleFavorite(for itemId: UUID) {
        favoritesStore.toggle(itemId)
        load()
    }
}

// MARK: - Private Functions
private extension CollectionDetailViewModel {
    
    func collectionIndex() -> Int? {
        allCollections.firstIndex { $0.id == collectionId }
    }
    
    func refreshDuplicates() {
        guard let items = collection?.items.elements else {
            duplicates = [:]
            duplicateLabels = [:]
            return
        }
        duplicates = duplicateService.findDuplicates(in: items)
        duplicateLabels = duplicateService.duplicateLabels(in: items)
    }
}
