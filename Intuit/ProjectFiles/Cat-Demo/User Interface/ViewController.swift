// Copyright © 2021 Intuit, Inc. All rights reserved.
import UIKit

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    let viewModel = ViewModel()
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredBreeds: [CatBreed] = []
    private var currentSort: SortOption = .nameAZ
    private var showFavoritesOnly = false
    private var selectedOrigin: String? = nil

    private enum SortOption {
        case nameAZ, nameZA, lifeSpanAsc, lifeSpanDesc

        var title: String {
            switch self {
            case .nameAZ:       return "Name A→Z"
            case .nameZA:       return "Name Z→A"
            case .lifeSpanAsc:  return "Life Span: Shortest First"
            case .lifeSpanDesc: return "Life Span: Longest First"
            }
        }
    }

    private var displayedBreeds: [CatBreed] {
        let isSearching = searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
        var base = isSearching ? filteredBreeds : (viewModel.catBreeds ?? [])
        if showFavoritesOnly {
            base = base.filter { FavoritesManager.shared.isFavorite($0.id ?? "") }
        }
        if let origin = selectedOrigin {
            base = base.filter { $0.origin == origin }
        }
        return applySorting(to: base)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Cat Breeds"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.keyboardDismissMode = .onDrag

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Breeds"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        navigationItem.rightBarButtonItem = makeFilterButton()

        viewModel.catDataDelegate = self
        viewModel.getBreeds()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: animated)
            tableView.reloadRows(at: [selected], with: .none)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardFrameInView = view.convert(keyboardFrame, from: view.window)
        let bottomInset = view.bounds.maxY - keyboardFrameInView.minY
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: max(0, bottomInset), right: 0)
        tableView.contentInset = inset
        tableView.scrollIndicatorInsets = inset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }

    // MARK: - Filter / Sort Menu

    private func makeFilterButton() -> UIBarButtonItem {
        let isFiltered = showFavoritesOnly || selectedOrigin != nil
        let icon = isFiltered ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"

        let sortSection = UIMenu(title: "Sort", options: .displayInline, children: makeSortActions())
        let favSection  = UIMenu(title: "Favorites", options: .displayInline, children: makeFavoriteActions())
        let originSection = UIMenu(title: "Filter", options: .displayInline, children: [makeOriginSubmenu()])
        let menu = UIMenu(title: "", children: [sortSection, favSection, originSection])

        return UIBarButtonItem(image: UIImage(systemName: icon), menu: menu)
    }

    private func makeSortActions() -> [UIAction] {
        [.nameAZ, .nameZA, .lifeSpanAsc, .lifeSpanDesc].map { option in
            UIAction(title: option.title, state: currentSort == option ? .on : .off) { [weak self] _ in
                guard let self = self else { return }
                self.currentSort = option
                self.tableView.reloadData()
                self.navigationItem.rightBarButtonItem = self.makeFilterButton()
            }
        }
    }

    private func makeFavoriteActions() -> [UIAction] {
        [UIAction(
            title: "Show Favorites Only",
            image: UIImage(systemName: showFavoritesOnly ? "heart.fill" : "heart"),
            state: showFavoritesOnly ? .on : .off
        ) { [weak self] _ in
            guard let self = self else { return }
            self.showFavoritesOnly.toggle()
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem = self.makeFilterButton()
        }]
    }

    private func makeOriginSubmenu() -> UIMenu {
        let origins = Set((viewModel.catBreeds ?? []).compactMap {
            $0.origin?.trimmingCharacters(in: .whitespaces)
        })
        .filter { !$0.isEmpty }
        .sorted()

        let allAction = UIAction(title: "All Origins", state: selectedOrigin == nil ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.selectedOrigin = nil
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem = self.makeFilterButton()
        }

        let originActions = origins.map { origin in
            UIAction(title: origin, state: self.selectedOrigin == origin ? .on : .off) { [weak self] _ in
                guard let self = self else { return }
                self.selectedOrigin = origin
                self.tableView.reloadData()
                self.navigationItem.rightBarButtonItem = self.makeFilterButton()
            }
        }

        return UIMenu(title: "Origin", image: UIImage(systemName: "globe"), children: [allAction] + originActions)
    }

    // MARK: - Sorting

    private func applySorting(to breeds: [CatBreed]) -> [CatBreed] {
        switch currentSort {
        case .nameAZ:       return breeds.sorted { ($0.name ?? "") < ($1.name ?? "") }
        case .nameZA:       return breeds.sorted { ($0.name ?? "") > ($1.name ?? "") }
        case .lifeSpanAsc:  return breeds.sorted { lifeSpanMin($0) < lifeSpanMin($1) }
        case .lifeSpanDesc: return breeds.sorted { lifeSpanMin($0) > lifeSpanMin($1) }
        }
    }

    private func lifeSpanMin(_ breed: CatBreed) -> Int {
        guard let span = breed.life_span else { return 0 }
        let part = span.components(separatedBy: CharacterSet(charactersIn: "-– ")).first ?? ""
        return Int(part.trimmingCharacters(in: .whitespaces)) ?? 0
    }
}

// MARK: - TableView
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedBreeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let catCell = tableView.dequeueReusableCell(withIdentifier: "CatTableViewCell") as! CatTableViewCell
        catCell.populateWith(breed: displayedBreeds[indexPath.row])
        return catCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < displayedBreeds.count else { return }
        navigateToDetail(forIndex: indexPath.row)
    }
}

// MARK: - CatDataDelegate
extension ViewController: CatDataDelegate {
    func breedsChangedNotification() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            // Rebuild menu now that origin list is available
            self.navigationItem.rightBarButtonItem = self.makeFilterButton()
        }
    }

    func imageChangedNotification() {}
}

// MARK: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filteredBreeds = searchText.isEmpty ? [] : (viewModel.catBreeds ?? []).filter {
            $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
        }
        tableView.reloadData()
    }
}


extension ViewController {
    func navigateToDetail(forIndex index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.breed = displayedBreeds[index]
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
