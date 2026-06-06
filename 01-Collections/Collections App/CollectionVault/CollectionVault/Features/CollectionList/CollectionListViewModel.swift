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
    weak var coordinator: CollectionListNavigationDelegate?
    
    init(repository: CollectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func load() {
        collections = repository.fetch()
        onUpdate?()
    }
    
    func selectCollection(at index: Int) {
        guard collections.indices.contains(index) else { return }
        coordinator?.didSelectCollection(id: collections[index].id)
    }
    
    func addCollection(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let new = Collection(name: trimmedName)
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
    
    func renameCollection(at index: Int, newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, collections.indices.contains(index) else { return }
        collections[index].name = trimmedName
        repository.save(collections)
        onUpdate?()
    }
}
