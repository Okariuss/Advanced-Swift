//
//  UserDefaultsCollectionRepository.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

final class UserDefaultsCollectionRepository: CollectionRepositoryProtocol {
    private let key = "collections_vault_data"
    
    func fetch() -> [Collection] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Collection].self, from: data)
        else { return [] }
        return decoded
    }
    
    func save(_ collections: [Collection]) {
        guard let data = try? JSONEncoder().encode(collections) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
