//
//  UserDefaultsCollectionRepository.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

final class UserDefaultsCollectionRepository: CollectionRepositoryProtocol {
    
    private let collectionsKey = "cv_collections_data"
    private let historyKey = "cv_search_history"
    
    private var cachedHistory: OrderedSet<String>?
    
    func fetch() -> [Collection] {
        guard let data = UserDefaults.standard.data(forKey: collectionsKey),
              let decoded = try? JSONDecoder().decode([Collection].self, from: data)
        else {
            return []
        }
        return decoded
    }
    
    func save(_ collections: [Collection]) {
        guard let data = try? JSONEncoder().encode(collections) else { return }
        UserDefaults.standard.set(data, forKey: collectionsKey)
    }
    
    func updateItem(_ item: VaultItem, in collectionId: UUID) {
        var collections = fetch()
        
        guard let collectionIndex = collections.firstIndex(where: { $0.id == collectionId }),
              collections[collectionIndex].items.contains(item)
        else {
            return
        }
        
        collections[collectionIndex].items.update(item)
        
        save(collections)
    }
    
    func deleteItem(_ itemId: UUID, in collectionId: UUID) {
        var collections = fetch()
        
        guard let collectionIndex = collections.firstIndex(where: { $0.id == collectionId }) else {
            return
        }
        
        let items = collections[collectionIndex].items.elements
        guard let itemsIndex = items.firstIndex(where: { $0.id == itemId }) else { return }
        
        collections[collectionIndex].items.remove(IndexSet(integer: itemsIndex))
        
        save(collections)
    }
    
    var globalSearchHistory: OrderedSet<String> {
        get {
            if let cached = cachedHistory { return cached }
            guard let data = UserDefaults.standard.data(forKey: historyKey),
                  let decoded = try? JSONDecoder().decode(OrderedSet<String>.self, from: data) else {
                return []
            }
            cachedHistory = decoded
            return decoded
        }
        
        set {
            cachedHistory = newValue
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
}
