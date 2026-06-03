//
//  AppCoordinator.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let container: AppContainer
    
    init(window: UIWindow, container: AppContainer) {
        self.window = window
        self.container = container
    }
    
    func start() {
        let tabBar = UITabBarController()
        tabBar.viewControllers = [
            makeCollectionsTab(),
            makeFavoritesTab()
        ]
        window.rootViewController = tabBar
        window.makeKeyAndVisible()
    }
    
    private func makeCollectionsTab() -> UIViewController {
        let vm = CollectionListViewModel(repository: container.repository)
        let vc = CollectionListViewController(viewModel: vm, favoritesStore: container.favoritesStore)
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(title: L10N.General.collections, image: .init(systemName: "folder"), selectedImage: .init(systemName: "folder.fill"))
        return nav
    }
    
    private func makeFavoritesTab() -> UIViewController {
        let vm = FavoritesViewModel(repository: container.repository, favoritesStore: container.favoritesStore)
        let vc = FavoritesViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(title: L10N.General.favorites, image: .init(systemName: "star"), selectedImage: .init(systemName: "star.fill"))
        return nav
    }
}
