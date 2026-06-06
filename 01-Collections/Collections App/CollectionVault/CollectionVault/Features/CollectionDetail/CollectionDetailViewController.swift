//
//  CollectionDetailViewController.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

import UIKit

final class CollectionDetailViewController: UIViewController, AlertPresenting {
    private let viewModel: CollectionDetailViewModel
    
    var onSearchRequested: (() -> Void)?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "itemCell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private let emptyStateView = EmptyStateView(iconName: "tray", title: L10N.CollectionDetail.collectionDetailEmptyStateMessage, description: L10N.CollectionDetail.collectionDetailEmptyStateDescription)

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
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
}

extension CollectionDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.collection?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        guard let item = viewModel.collection?.items.elements[indexPath.row] else { return cell }
        
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        
        let normalized = DuplicateService.normalized(item.title)
        if let count = viewModel.duplicates[normalized], count > 1 {
            config.secondaryText = L10N.CollectionDetail.collectionDetailCellDescriptionError(count)
            config.secondaryTextProperties.color = CVDesign.Color.warning
        } else {
            config.secondaryText = L10N.CollectionDetail.collectionDetailCellDescription
            config.secondaryTextProperties.color = CVDesign.Color.secondaryLabel
        }
        
        let isFav = viewModel.isFavorite(id: item.id)
        let favButton = UIButton(type: .custom)
        let favImage = UIImage(systemName: isFav ? "star.fill" : "star")
        favButton.setImage(favImage, for: .init())
        favButton.tintColor = isFav ? CVDesign.Color.favorite : CVDesign.Color.secondaryLabel
        favButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        favButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.toggleFavorite(for: item.id)
        }, for: .touchUpInside)
        
        cell.contentConfiguration = config
        cell.accessoryView = favButton
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.didSelectItem(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        confirmDeleteItem(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let rename = UIContextualAction(style: .normal, title: L10N.General.rename) { [weak self] _, _, completion in
            self?.renameItemTapped(at: indexPath.row)
            completion(true)
        }
        
        rename.backgroundColor = CVDesign.Color.accent
        rename.image = UIImage(systemName: "pencil")
        return UISwipeActionsConfiguration(actions: [rename])
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = viewModel.collection?.items.elements[indexPath.row] else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu(children: []) }
            
            let rename = UIAction(title: L10N.General.rename, image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.renameItemTapped(at: indexPath.row)
            }
            
            let isFav = self.viewModel.isFavorite(id: item.id)
            let favTitle = isFav ? L10N.CollectionDetail.collectionDetailRemoveFromFavorite : L10N.CollectionDetail.collectionDetailAddToFavorite
            let favImage = UIImage(systemName: isFav ? "star.slash" : "star")
            let favorite = UIAction(title: favTitle, image: favImage) { [weak self] _ in
                self?.viewModel.toggleFavorite(for: item.id)
            }
            
            let delete = UIAction(title: L10N.General.delete, image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.viewModel.deleteItems(at: IndexSet(integer: indexPath.row))
            }
            
            return UIMenu(title: item.title, children: [rename, favorite, delete])
        }
    }
}

private extension CollectionDetailViewController {
    
    func setupUI() {
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = CVDesign.Color.bg
        
        setupTable()
        setupNav()
        setupEmptyState()
        
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            self.title = self.viewModel.collectionName
            self.tableView.reloadData()
            let isEmpty = self.viewModel.collection?.items.isEmpty ?? true
            self.emptyStateView.isHidden = !isEmpty
            self.editButtonItem.isHidden = isEmpty
        }
    }
    
    func setupTable() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupNav() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemTapped))
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchTapped))
        navigationItem.rightBarButtonItems = [addButton, searchButton]
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    func setupEmptyState() {
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CVDesign.Spacing.spacing800),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CVDesign.Spacing.spacing800)
        ])
    }
    
    @objc func addItemTapped() {
        presentNameAlert(
            title: L10N.CollectionDetail.collectionDetailAlertAddTitle,
            message: L10N.CollectionDetail.collectionDetailAlertAddMessage,
            placeholder: L10N.CollectionDetail.collectionDetailAlertAddTextField,
            confirmTitle: L10N.General.add,
            currentValue: nil
        ) { [weak self] text in
            self?.viewModel.addItem(title: text)
        }
    }
    
    @objc func searchTapped() {
        onSearchRequested?()
    }
    
    func renameCollectionTapped() {
        presentNameAlert(
            title: L10N.General.rename,
            message: L10N.General.rename,
            placeholder: "",
            confirmTitle: L10N.General.save,
            currentValue: viewModel.collectionName
        ) { [weak self] text in
            self?.viewModel.renameCollection(newName: text)
        }
    }
    
    func renameItemTapped(at index: Int) {
        let items = viewModel.collection?.items.elements ?? []
        guard items.indices.contains(index) else { return }
        presentNameAlert(
            title: L10N.General.rename,
            message: nil,
            placeholder: L10N.CollectionDetail.collectionDetailAlertAddTitle,
            confirmTitle: L10N.General.save,
            currentValue: items[index].title
        ) { [weak self] newTitle in
            self?.viewModel.renameItem(at: index, newTitle: newTitle)
        }
    }
    
    func confirmDeleteItem(at indexPath: IndexPath) {
        let items = viewModel.collection?.items.elements ?? []
        guard items.indices.contains(indexPath.row) else { return }
        let name = items[indexPath.row].title
        presentDestructiveConfirmation(
            title: L10N.CollectionList.collectionListDeleteConfirmTitle(name),
            message: L10N.CollectionList.collectionListDeleteConfirmMessage(name),
            destructiveTitle: L10N.General.delete
        ) { [weak self] in
            guard let self else { return }
            self.viewModel.deleteItems(at: IndexSet(integer: indexPath.row))
        }
    }
}
