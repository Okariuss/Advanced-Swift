//
//  AppContainer.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

protocol AppContainerProtocol: AnyObject {
    var repository: CollectionRepositoryProtocol { get }
    var favoritesStore: FavoritesStoreProtocol { get }
}

final class AppContainer: AppContainerProtocol {
    let repository: CollectionRepositoryProtocol
    let favoritesStore: FavoritesStoreProtocol
    
    init() {
        self.repository = UserDefaultsCollectionRepository()
        self.favoritesStore = FavoritesStore()
    }
}
