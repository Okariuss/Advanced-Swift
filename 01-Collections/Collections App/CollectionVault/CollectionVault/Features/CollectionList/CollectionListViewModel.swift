//
//  CollectionListViewModel.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

final class CollectionListViewModel {
    private let repository: CollectionRepositoryProtocol
    private(set) var collections: [Collection] = []
    
    var onUpdate: (() -> Void)?
    
    init(repository: CollectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func load() {
        collections = repository.fetch()
        onUpdate?()
    }
    
    func addCollection(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let new = Collection(id: UUID(), name: trimmedName, items: [])
        collections.append(new)
        repository.save(collections)
        onUpdate?()
    }
    
    func deleteCollection(at index: Int) {
        guard collections.indices.contains(index) else { return }
        collections.remove(at: index)
        repository.save(collections)
        onUpdate?()
    }
}
