//
//  ItemDetailViewController.swift
//  CollectionVault
//
//  Created by Okan Orkun on 4.06.2026.
//

import UIKit

final class ItemDetailViewController: UIViewController, AlertPresenting {

    private let viewModel: ItemDetailViewModel
    
    private enum ReuseID {
        static let value1 = "value1Cell"
        static let action = "actionCell"
    }

    init(viewModel: ItemDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: ReuseID.value1)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: ReuseID.action)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        viewModel.onUpdate = { [weak self] in
            self?.title = self?.viewModel.title
            self?.tableView.reloadData()
        }
    }
}

private extension ItemDetailViewController {

    func setupUI() {
        title = viewModel.title

        view.backgroundColor = CVDesign.Color.bg

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ItemDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        ItemDetailSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ItemDetailSection(rawValue: section)?.rowCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = ItemDetailSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
            
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseID.value1, for: indexPath)
            guard let row = ItemDetailInfoRow(rawValue: indexPath.row) else { return cell }
            var config = UIListContentConfiguration.valueCell()
            
            switch row {
            case .collection:
                config.text = L10N.ItemDetail.itemDetailCollectionName
                config.secondaryText = viewModel.collectionName
            case .created:
                config.text = L10N.ItemDetail.itemDetailCreatedName
                config.secondaryText = viewModel.createdDateText
            }
            cell.contentConfiguration = config
            cell.selectionStyle = .none
            return cell
            
        case .actions:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseID.action, for: indexPath)
            guard let row = ItemDetailActionRow(rawValue: indexPath.row) else { return cell }
            var config = cell.defaultContentConfiguration()
            
            switch row {
            case .favorite:
                config.text = viewModel.isFavorite
                    ? L10N.ItemDetail.itemDetailRemoveFromFavorites
                    : L10N.ItemDetail.itemDetailAddToFavorites
                config.image = UIImage(systemName: viewModel.isFavorite ? "star.fill" : "star")
                config.imageProperties.tintColor = viewModel.isFavorite ? CVDesign.Color.favorite : CVDesign.Color.accent
                cell.accessoryType = .none
                
            case .rename:
                config.text = L10N.General.rename
                config.image = UIImage(systemName: "pencil")
                config.imageProperties.tintColor = CVDesign.Color.accent
                cell.accessoryType = .disclosureIndicator
                
            case .delete:
                config.text = L10N.General.delete
                config.image = UIImage(systemName: "trash")
                config.imageProperties.tintColor = CVDesign.Color.destructive
                cell.accessoryType = .none
            }
            
            cell.contentConfiguration = config
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
 
        guard let section = ItemDetailSection(rawValue: indexPath.section),
              section == .actions,
              let row = ItemDetailActionRow(rawValue: indexPath.row)
        else { return }
 
        switch row {
        case .favorite:
            viewModel.toggleFavorite()
 
        case .rename:
            presentNameAlert(
                title: L10N.General.rename,
                message: nil,
                placeholder: viewModel.title,
                confirmTitle: L10N.General.save,
                currentValue: viewModel.title
            ) { [weak self] newTitle in
                self?.viewModel.renameItem(newTitle: newTitle)
            }
 
        case .delete:
            presentDestructiveConfirmation(
                title: L10N.ItemDetail.itemDetailDeleteConfirmTitle(viewModel.item.title),
                message: L10N.ItemDetail.itemDetailDeleteConfirmMessage(viewModel.item.title),
                destructiveTitle: L10N.General.delete
            ) { [weak self] in
                self?.viewModel.deleteItem()
            }
        }
    }
}
