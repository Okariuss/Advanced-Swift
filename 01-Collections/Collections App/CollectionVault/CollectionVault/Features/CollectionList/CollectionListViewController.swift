//
//  CollectionListViewController.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import UIKit

final class CollectionListViewController: UIViewController {
    
    private let viewModel: CollectionListViewModel
    
    init(viewModel: CollectionListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private let emptyStateView = EmptyStateView(iconName: "square.stack.3d.up.slash", title: L10N.CollectionList.collectionListEmptyStateMessage, description: L10N.CollectionList.collectionListEmptyStateDescription)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    private func setupUI() {
        title = L10N.General.appName
        view.backgroundColor = CVDesign.Color.bg
        
        setupTable()
        setupNav()
        setupEmptyState()
        
        viewModel.onUpdate = { [weak self] in
            self?.updateUI()
        }
    }
    
    @objc private func addButtonTapped() {
        let alert = UIAlertController(title: L10N.CollectionList.collectionListAlertAddTitle, message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = L10N.CollectionList.collectionListAlertAddTextField }
        alert.addAction(UIAlertAction(title: L10N.General.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10N.General.add, style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text else { return }
            self?.viewModel.addCollection(name: name)
        })
        present(alert, animated: true)
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
    
    private func setupNav() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.leftBarButtonItem = editButtonItem
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
        emptyStateView.isHidden = !viewModel.collections.isEmpty
    }
}

extension CollectionListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let collection = viewModel.collections[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = collection.name
        config.secondaryText = L10N.CollectionList.collectionListItemCount(collection.items.count)
        config.image = UIImage(systemName: "folder.fill")
        config.imageProperties.tintColor = CVDesign.Color.accent
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteCollection(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let collection = viewModel.collections[indexPath.row]
        let detailViewModel = CollectionDetailViewModel(
            repository: UserDefaultsCollectionRepository(),
            collectionId: collection.id
        )
        let detailViewController = CollectionDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
