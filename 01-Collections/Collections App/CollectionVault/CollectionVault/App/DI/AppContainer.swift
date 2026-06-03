//
//  AppContainer.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

protocol AppContainerProtocol: AnyObject {
    var repository: CollectionRepositoryProtocol { get }
    var favoritesStore: FavoritesStore { get }
}

final class AppContainer {
    let repository: CollectionRepositoryProtocol
    let favoritesStore: FavoritesStore
    
    init() {
        self.repository = UserDefaultsCollectionRepository()
        self.favoritesStore = FavoritesStore()
    }
}
