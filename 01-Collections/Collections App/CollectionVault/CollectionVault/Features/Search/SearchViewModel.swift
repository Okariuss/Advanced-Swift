//
//  SearchViewModel.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

import Foundation

final class SearchViewModel {
    private let repository: CollectionRepositoryProtocol
    private(set) var results: [(item: VaultItem, collectionId: UUID, collectionName: String)] = []
    
    weak var coordinator: CollectionDetailNavigationDelegate?
    var onUpdate: (() -> Void)?
    
    var searchHistory: OrderedSet<String> {
        return repository.globalSearchHistory
    }
    
    init(repository: CollectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func filterResults(with query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            onUpdate?()
            return
        }
        
        let lowercased = trimmed.lowercased()
        
        results = repository.fetch().flatMap { collection in
            collection.items.elements
                .filter { $0.title.lowercased().contains(lowercased) }
                .map { (item: $0, collectionId: collection.id, collectionName: collection.name) }
        }
        onUpdate?()
    }
    
    func commitSearchHistory(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        repository.globalSearchHistory.insert(trimmed)
        onUpdate?()
    }
    
    func deleteHistoryItem(at index: Int) {
        repository.globalSearchHistory.remove(IndexSet(integer: index))
        onUpdate?()
    }
    
    func clearHistory() {
        repository.globalSearchHistory.removeAll()
        onUpdate?()
    }
    
    func selectResult(at index: Int) {
        guard results.indices.contains(index) else { return }
        
        let result = results[index]
        
        coordinator?.navigateToItemDetail(
            item: result.item,
            collectionId: result.collectionId,
            collectionName: result.collectionName
        )
    }
}
