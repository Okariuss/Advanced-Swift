//
//  CollectionsCoordinator.swift
//  CollectionVault
//
//  Created by Okan Orkun on 4.06.2026.
//

import UIKit

protocol ItemDetailNavigationDelegate: AnyObject {
    func didDeleteItem()
}

protocol CollectionListNavigationDelegate: AnyObject {
    func didSelectCollection(id: UUID)
}

protocol CollectionDetailNavigationDelegate: ItemDetailNavigationDelegate {
    func navigateToSearch()
    func navigateToItemDetail(item: VaultItem, collectionId: UUID, collectionName: String)
}

final class CollectionsCoordinator: CollectionListNavigationDelegate, CollectionDetailNavigationDelegate {
    
    private let navigationController: UINavigationController
    private let container: AppContainerProtocol
    
    init(navigationController: UINavigationController, container: AppContainerProtocol) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let listVC = CollectionListBuilder.make(container: container, coordinator: self)
        navigationController.setViewControllers([listVC], animated: false)
    }
    
    func didSelectCollection(id: UUID) {
        let detailVC = CollectionDetailBuilder.make(container: container, collectionId: id, coordinator: self)
        navigationController.pushViewController(detailVC, animated: true)
    }
    
    func navigateToSearch() {
        let searchVC = SearchBuilder.make(container: container, coordinator: self)
        navigationController.pushViewController(searchVC, animated: true)
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
