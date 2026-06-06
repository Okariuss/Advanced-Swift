//
//  Collection.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

struct Collection: Codable, Identifiable {
    let id: UUID
    var name: String
    var items: OrderedSet<VaultItem>
    
    init(id: UUID = UUID(), name: String, items: OrderedSet<VaultItem> = []) {
        self.id = id
        self.name = name
        self.items = items
    }
}
