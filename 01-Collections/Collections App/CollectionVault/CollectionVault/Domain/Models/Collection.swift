//
//  Collection.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

struct Collection: Identifiable, Codable {
    let id: UUID
    var name: String
    var items: OrderedSet<VaultItem>
}
