//
//  CollectionListViewController.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import UIKit

final class CollectionListViewController: UIViewController, AlertPresenting {
    
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
    
    private let emptyStateView = EmptyStateView(
        iconName: "square.stack.3d.up.slash",
        title: L10N.CollectionList.collectionListEmptyStateMessage,
        description: L10N.CollectionList.collectionListEmptyStateDescription
    )
    
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
        guard editingStyle == .delete else { return }
        confirmDeleteCollection(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCollection(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let rename = UIContextualAction(style: .normal, title: L10N.General.rename) { [weak self] _, _, completion in
            self?.renameButtonTapped(at: indexPath.row)
            completion(true)
        }
        rename.backgroundColor = CVDesign.Color.accent
        rename.image = UIImage(systemName: "pencil")
        return UISwipeActionsConfiguration(actions: [rename])
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let collection = viewModel.collections[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu(children: []) }
 
            let rename = UIAction(
                title: L10N.General.rename,
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                self?.renameButtonTapped(at: indexPath.row)
            }
            let delete = UIAction(
                title: L10N.General.delete,
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.confirmDeleteCollection(at: indexPath)
            }
            return UIMenu(title: collection.name, children: [rename, delete])
        }
    }
}

private extension CollectionListViewController {
    func setupUI() {
        title = L10N.General.appName
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = CVDesign.Color.bg
        
        setupTable()
        setupNav()
        setupEmptyState()
        
        viewModel.onUpdate = { [weak self] in
            self?.updateUI()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    func setupEmptyState() {
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CVDesign.Spacing.spacing200),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CVDesign.Spacing.spacing200)
        ])
    }
    
    func updateUI() {
        tableView.reloadData()
        emptyStateView.isHidden = !viewModel.collections.isEmpty
        editButtonItem.isEnabled = !viewModel.collections.isEmpty
    }
    
    @objc func addButtonTapped() {
        presentNameAlert(
            title: L10N.CollectionList.collectionListAlertAddTitle,
            message: nil,
            placeholder: L10N.CollectionList.collectionListAlertAddTextField,
            confirmTitle: L10N.General.add,
            currentValue: nil
        ) { [weak self] name in
            self?.viewModel.addCollection(name: name)
        }
    }
    
    @objc func renameButtonTapped(at index: Int) {
        let current = viewModel.collections[index].name
        presentNameAlert(
            title: L10N.General.rename,
            message: nil,
            placeholder: L10N.CollectionList.collectionListAlertAddTitle,
            confirmTitle: L10N.General.save,
            currentValue: current
        ) { [weak self] name in
            self?.viewModel.renameCollection(at: index, newName: name)
        }
    }
    
    func confirmDeleteCollection(at indexPath: IndexPath) {
        let name = viewModel.collections[indexPath.row].name
        presentDestructiveConfirmation(
            title: L10N.CollectionList.collectionListDeleteConfirmTitle(name),
            message: L10N.CollectionList.collectionListDeleteConfirmMessage(name),
            destructiveTitle: L10N.General.delete
        ) { [weak self] in
            guard let self else { return }
            self.viewModel.deleteCollection(at: indexPath.row)
            if self.viewModel.collections.isEmpty {
                self.emptyStateView.isHidden = false
            }
        }
    }
}
