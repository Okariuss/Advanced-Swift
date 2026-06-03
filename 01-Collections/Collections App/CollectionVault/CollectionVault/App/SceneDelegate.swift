//
//  SceneDelegate.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let repository = UserDefaultsCollectionRepository()
        let viewModel = CollectionListViewModel(repository: repository)
        let rootVC = CollectionListViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: rootVC)
        navigationController.navigationBar.prefersLargeTitles = true
        
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
}
