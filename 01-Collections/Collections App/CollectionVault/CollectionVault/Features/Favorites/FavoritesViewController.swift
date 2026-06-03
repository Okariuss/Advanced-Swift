//
//  FavoritesViewController.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

import UIKit

final class FavoritesViewController: UIViewController {
    
    private let viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "favoriteCell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private let emptyStateView = EmptyStateView(
        iconName: "star.slash",
        title: L10N.Favorites.favoritesEmptyStateMessage,
        description: L10N.Favorites.favoritesEmptyStateDescription
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }
    
    private func setupUI() {
        title = L10N.General.favorites
        view.backgroundColor = CVDesign.Color.bg
        
        setupTable()
        setupEmptyState()
        
        viewModel.onUpdate = { [weak self] in
            self?.updateUI()
        }
    }
    
    private func setupTable() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CVDesign.Spacing.spacing200),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CVDesign.Spacing.spacing200)
        ])
    }
    
    private func updateUI() {
        tableView.reloadData()
        emptyStateView.isHidden = !viewModel.favoriteItems.isEmpty
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.favoriteItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath)
        let entry = viewModel.favoriteItems[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = entry.item.title
        config.secondaryText = entry.collectionName
        config.secondaryTextProperties.color = CVDesign.Color.secondaryLabel
        cell.contentConfiguration = config
        
        let favButton = UIButton(type: .custom)
        favButton.setImage(UIImage(systemName: "star.fill"), for: .init())
        favButton.tintColor = .systemYellow
        favButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        favButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.toggleFavorite(for: entry.item.id)
        }, for: .touchUpInside)
        
        cell.accessoryView = favButton
        return cell
    }
}
