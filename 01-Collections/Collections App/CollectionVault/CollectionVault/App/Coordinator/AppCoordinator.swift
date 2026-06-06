//
//  AppCoordinator.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

import UIKit
 
final class AppCoordinator {
    private let window: UIWindow
    private let container: AppContainerProtocol
    
    private var collectionsCoordinator: CollectionsCoordinator?
    private var favoritesCoordinator: FavoritesCoordinator?
    
    init(window: UIWindow, container: AppContainerProtocol) {
        self.window = window
        self.container = container
    }
    
    func start() {
        let tabBar = UITabBarController()
        
        let collectionsNav = UINavigationController()
        collectionsNav.navigationBar.prefersLargeTitles = true
        let collectionsCoordinator = CollectionsCoordinator(navigationController: collectionsNav, container: container)
        self.collectionsCoordinator = collectionsCoordinator
        collectionsCoordinator.start()
        collectionsNav.tabBarItem = UITabBarItem(
            title: L10N.General.collections,
            image: .init(systemName: "folder"),
            selectedImage: .init(systemName: "folder.fill")
        )
        
        let favoritesNav = UINavigationController()
        favoritesNav.navigationBar.prefersLargeTitles = true
        let favoritesCoordinator = FavoritesCoordinator(navigationController: favoritesNav, container: container)
        self.favoritesCoordinator = favoritesCoordinator
        favoritesCoordinator.start()
        favoritesNav.tabBarItem = UITabBarItem(
            title: L10N.General.favorites,
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )
        
        tabBar.viewControllers = [collectionsNav, favoritesNav]
        
        window.rootViewController = tabBar
        window.makeKeyAndVisible()
    }
}
