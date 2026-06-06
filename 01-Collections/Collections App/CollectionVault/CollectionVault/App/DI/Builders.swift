//
//  Builders.swift
//  CollectionVault
//
//  Created by Okan Orkun on 4.06.2026.
//

import UIKit

final class CollectionListBuilder {
    static func make(
        container: AppContainerProtocol,
        coordinator: CollectionListNavigationDelegate
    ) -> CollectionListViewController {
        let vm = CollectionListViewModel(repository: container.repository)
        vm.coordinator = coordinator
        return CollectionListViewController(viewModel: vm)
    }
}

final class CollectionDetailBuilder {
    static func make(
        container: AppContainerProtocol,
        collectionId: UUID,
        coordinator: CollectionDetailNavigationDelegate
    ) -> CollectionDetailViewController {
        let vm = CollectionDetailViewModel(
            repository: container.repository,
            collectionId: collectionId,
            favoritesStore: container.favoritesStore
        )
        vm.coordinator = coordinator
        let vc = CollectionDetailViewController(viewModel: vm)

        vc.onSearchRequested = { [weak coordinator] in
            coordinator?.navigateToSearch()
        }
        return vc
    }
}

final class SearchBuilder {
    static func make(
        container: AppContainerProtocol,
        coordinator: CollectionDetailNavigationDelegate
    ) -> SearchViewController {
        let vm = SearchViewModel(repository: container.repository)
        vm.coordinator = coordinator
        return SearchViewController(viewModel: vm)
    }
}

final class ItemDetailBuilder {
    static func make(
        item: VaultItem,
        collectionName: String,
        favoritesStore: FavoritesStoreProtocol,
        collectionId: UUID,
        repository: CollectionRepositoryProtocol,
        coordinator: ItemDetailNavigationDelegate
    ) -> ItemDetailViewController {
        let vm = ItemDetailViewModel(
            item: item,
            collectionName: collectionName,
            collectionId: collectionId,
            repository: repository,
            favoritesStore: favoritesStore,
            coordinator: coordinator
        )
        
        return ItemDetailViewController(viewModel: vm)
    }
}

final class FavoritesBuilder {
    static func makeFavorites(
        container: AppContainerProtocol,
        coordinator: FavoritesNavigationDelegate
    ) -> FavoritesViewController {
        let vm = FavoritesViewModel(
            repository: container.repository,
            favoritesStore: container.favoritesStore
        )
        vm.coordinator = coordinator
        return FavoritesViewController(viewModel: vm)
    }
}
