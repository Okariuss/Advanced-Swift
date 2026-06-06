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
    private let favoritesStore: FavoritesStoreProtocol
    
    private(set) var collection: Collection?
    private(set) var duplicates: [String: Int] = [:]
    private var allCollections: [Collection] = []
    
    weak var coordinator: CollectionDetailNavigationDelegate?
        
    var onUpdate: (() -> Void)?
    
    init(repository: CollectionRepositoryProtocol, collectionId: UUID, favoritesStore: FavoritesStoreProtocol) {
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
    
    var collectionName: String { collection?.name ?? "" }
    
    func addItem(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmed.isEmpty,
            let index = collectionIndex()
        else {
            return
        }
        
        let newItem = VaultItem(id: UUID(), title: trimmed, createdAt: Date())
        allCollections[index].items.append(newItem)
        save()
    }
    
    func renameItem(at offset: Int, newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let colIdx = collectionIndex() else { return }
        
        let items = allCollections[colIdx].items.elements
        guard items.indices.contains(offset) else { return }
        
        var updatedItem = items[offset]
        updatedItem.title = trimmed
        allCollections[colIdx].items.update(updatedItem)
        save()
    }
    
    func renameCollection(newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = collectionIndex() else { return }
        
        allCollections[index].name = trimmed
        save()
    }
    
    func deleteItems(at offsets: IndexSet) {
        guard let index = collectionIndex() else { return }
        
        allCollections[index].items.remove(offsets)
        
        save()
    }
    
    func didSelectItem(at index: Int) {
        guard
            let collection = collection,
            collection.items.elements.indices.contains(index)
        else { return }

        let item = collection.items.elements[index]

        coordinator?.navigateToItemDetail(
            item: item,
            collectionId: collection.id,
            collectionName: collection.name
        )
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
    
    func save() {
        repository.save(allCollections)
        load()
    }
    
    func refreshDuplicates() {
        guard let items = collection?.items.elements else {
            duplicates = [:]
            return
        }
        duplicates = duplicateService.findDuplicates(in: items)
    }
}
