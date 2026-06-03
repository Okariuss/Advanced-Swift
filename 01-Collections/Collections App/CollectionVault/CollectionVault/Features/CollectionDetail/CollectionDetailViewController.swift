//
//  CollectionDetailViewController.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

import UIKit

final class CollectionDetailViewController: UIViewController {
    private let viewModel: CollectionDetailViewModel
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "itemCell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private let emptyStateView = EmptyStateView(iconName: "square.stack.3d.up.slash", title: L10N.CollectionList.collectionListEmptyStateMessage, description: L10N.CollectionList.collectionListEmptyStateDescription)

    init(viewModel: CollectionDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }
    
    private func setupUI() {
        view.backgroundColor = CVDesign.Color.bg
        
        setupTable()
        setupNav()
        setupEmptyState()
        
        viewModel.onUpdate = { [weak self] in
            self?.title = self?.viewModel.collection?.name
            self?.tableView.reloadData()
            self?.emptyStateView.isHidden = !(self?.viewModel.collection?.items.isEmpty ?? true)
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
    
    private func setupNav() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemTapped))
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchTapped))
        navigationItem.rightBarButtonItems = [addButton, searchButton]
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func addItemTapped() {
        let alert = UIAlertController(title: "Yeni Öğe", message: "Koleksiyona eklenecek başlık:", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Öğe başlığı" }
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Ekle", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text else { return }
            self?.viewModel.addItem(title: text)
        })
        present(alert, animated: true)
    }
    
    @objc private func searchTapped() {
        present(ViewController(), animated: true)
    }
}

extension CollectionDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.collection?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        guard let item = viewModel.collection?.items.elements[indexPath.row] else { return cell }
        
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        
        // Mükerrer Kayıt (Duplicate) Uyarısı - O(1) Check
        let normalized = item.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let count = viewModel.duplicates[normalized], count > 1 {
            config.secondaryText = "⚠️ Mükerrer Kayıt (\(count) kez)"
            config.secondaryTextProperties.color = CVDesign.Color.warning
        } else {
            config.secondaryText = "Kayıtlı Öğe"
            config.secondaryTextProperties.color = CVDesign.Color.secondaryLabel
        }
        
        cell.contentConfiguration = config
        
        // Favori Butonu (Apple HIG 44pt Touch Target)
        let favButton = UIButton(type: .custom)
        let favImage = UIImage(systemName: viewModel.isFavorite(id: item.id) ? "star.fill" : "star")
        favButton.setImage(favImage, for: .init())
        favButton.tintColor = viewModel.isFavorite(id: item.id) ? CVDesign.Color.favorite : CVDesign.Color.secondaryLabel
        favButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        favButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.toggleFavorite(for: item.id)
        }, for: .touchUpInside)
        
        cell.accessoryView = favButton
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteItems(at: IndexSet(integer: indexPath.row))
        }
    }
}
