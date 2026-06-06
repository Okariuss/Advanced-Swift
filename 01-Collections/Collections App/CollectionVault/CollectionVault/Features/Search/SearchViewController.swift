//
//  SearchViewController.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

import UIKit

final class SearchViewController: UIViewController {
    private let viewModel: SearchViewModel
    
    private enum ReuseID {
        static let result = "resultCell"
        static let history = "historyCell"
    }
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.searchBar.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = L10N.Search.searchPlaceholder
        return sc
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseID.result)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseID.history)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private var isDisplayingResults: Bool {
        searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        title = L10N.Search.searchTitle
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = CVDesign.Color.bg
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        setupTable()
        updateClearButton()
        
        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
            self?.updateClearButton()
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
    
    @objc private func clearHistoryTapped() {
        viewModel.clearHistory()
        updateClearButton()
    }
    
    private func updateClearButton() {
        navigationItem.rightBarButtonItem = viewModel.searchHistory.isEmpty ? nil :
        UIBarButtonItem(title: L10N.Search.searchHistoryClear, style: .plain, target: self, action: #selector(clearHistoryTapped))
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
 
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        viewModel.filterResults(with: query)
    }
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        viewModel.commitSearchHistory(query: query)
        searchBar.resignFirstResponder()
    }
 
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filterResults(with: "")
    }
 
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
 
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
 
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isDisplayingResults {
            return viewModel.results.isEmpty ? nil : L10N.Search.searchResultsHeader
        } else {
            return viewModel.searchHistory.isEmpty ? nil : L10N.Search.searchHistoryHeader
        }
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isDisplayingResults ? viewModel.results.count : viewModel.searchHistory.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isDisplayingResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseID.result, for: indexPath)
            let entry = viewModel.results[indexPath.row]
            var config = cell.defaultContentConfiguration()
            config.text = entry.item.title
            config.secondaryText = entry.collectionName
            config.secondaryTextProperties.color = CVDesign.Color.secondaryLabel
            config.image = UIImage(systemName: "doc.text")
            config.imageProperties.tintColor = CVDesign.Color.accent
            cell.contentConfiguration = config
            cell.accessoryType = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseID.history, for: indexPath)
            let query = viewModel.searchHistory.elements[indexPath.row]
            var config = cell.defaultContentConfiguration()
            config.text = query
            config.image = UIImage(systemName: "clock")
            config.imageProperties.tintColor = CVDesign.Color.secondaryLabel
            cell.contentConfiguration = config
 
            let arrowImageView = UIImageView(image: UIImage(systemName: "arrow.up.left"))
            arrowImageView.tintColor = CVDesign.Color.secondaryLabel
            arrowImageView.sizeToFit()
            cell.accessoryView = arrowImageView
            return cell
        }
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
 
        if isDisplayingResults {
            let entry = viewModel.results[indexPath.row]
            viewModel.commitSearchHistory(query: entry.item.title)
            viewModel.selectResult(at: indexPath.row)
        } else {
            let query = viewModel.searchHistory.elements[indexPath.row]
            searchController.searchBar.text = query
            searchController.isActive = true
            viewModel.filterResults(with: query)
            viewModel.commitSearchHistory(query: query)
        }
    }
 
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !isDisplayingResults else { return nil }
 
        let deleteAction = UIContextualAction(style: .destructive, title: L10N.General.delete) { [weak self] _, _, completion in
            self?.viewModel.deleteHistoryItem(at: indexPath.row)
            self?.updateClearButton()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
