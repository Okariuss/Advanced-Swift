//
//  CollectionRepositoryProtocol.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

protocol CollectionRepositoryProtocol: AnyObject {
    func fetch() -> [Collection]
    func save(_ collections: [Collection])
}
