//
//  CollectionRepositoryProtocol.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

protocol CollectionRepositoryProtocol: AnyObject {
    func fetch() -> [Collection]
    func save(_ collections: [Collection])
    
    func updateItem(_ item: VaultItem, in collectionId: UUID)
    func deleteItem(_ itemId: UUID, in collectionId: UUID)
    
    var globalSearchHistory: OrderedSet<String> { get set }
}
