//
//  FavoritesCoordinator.swift
//  CollectionVault
//
//  Created by Okan Orkun on 5.06.2026.
//

import UIKit

protocol FavoritesNavigationDelegate: ItemDetailNavigationDelegate {
    func navigateToItemDetail(item: VaultItem, collectionId: UUID, collectionName: String)
}

final class FavoritesCoordinator: FavoritesNavigationDelegate {
    
    private let navigationController: UINavigationController
    private let container: AppContainerProtocol
    
    init(navigationController: UINavigationController, container: AppContainerProtocol) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let favoritesVC = FavoritesBuilder.makeFavorites(container: container, coordinator: self)
        navigationController.setViewControllers([favoritesVC], animated: false)
    }
    
    func navigateToItemDetail(item: VaultItem, collectionId: UUID, collectionName: String) {
        let itemDetailVC = ItemDetailBuilder.make(
            item: item,
            collectionName: collectionName,
            favoritesStore: container.favoritesStore,
            collectionId: collectionId,
            repository: container.repository,
            coordinator: self
        )
        navigationController.pushViewController(itemDetailVC, animated: true)
    }
    
    func didDeleteItem() {
        navigationController.popViewController(animated: true)
    }
}
