//
//  ViewController.swift
//  Life-FormSerch
//
//  Created by Gwen Thelin on 12/11/24.
//

import UIKit

extension UITableViewCell {
	private struct AssociatedKeys {
		static var searchIDKey = "searchIDKey"
	}
	
	var searchID: Int {
		get {
			if let value = objc_getAssociatedObject(self, &AssociatedKeys.searchIDKey) as? Int {
				return value
			}
			return 0
		}
		set {
			objc_setAssociatedObject(self, &AssociatedKeys.searchIDKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}

class ViewController: UIViewController {
	var idToUseInSegue: Int?
	
	@IBOutlet weak var searchBar: UISearchBar! {
		didSet {
			searchBar.delegate = self
		}
	}
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var dataSource: UITableViewDiffableDataSource<Int, Result>!
	
	private var debounceTask: Task<Void, Never>?
	
	deinit {
		debounceTask?.cancel()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let searchBar = searchBar else { return }
		
		searchBar.placeholder = "Search"
		
		tableView.delegate = self
		
		setupTableView()
		configureDataSource()
	}
	
	func setupTableView() {
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchCell")
	}
	
	func configureDataSource() {
		dataSource = UITableViewDiffableDataSource<Int, Result>(tableView: tableView) {
			tableView, indexPath, result in
			let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
			
			var contentConfig = cell.defaultContentConfiguration()
			
			contentConfig.text = result.content
			contentConfig.secondaryText = result.title
			
			cell.searchID = result.id
			
			cell.contentConfiguration = contentConfig
			return cell
		}
	}
	func updateSnapshot(with results: [Result]) {
		var snapshot = NSDiffableDataSourceSnapshot<Int, Result>()
		snapshot.appendSections([0])
		snapshot.appendItems(results, toSection: 0)
		dataSource.apply(snapshot, animatingDifferences: true)
	}
	
	func startSpinning() {
		activityIndicator.isHidden = false
		activityIndicator.startAnimating()
	}
	
	func stopSpinning() {
		activityIndicator.stopAnimating()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let sender = sender as? UITableViewCell,
		   let destination = segue.destination as? DetailViewController
		{
			idToUseInSegue = sender.searchID
			destination.id = sender.searchID
		}
	}
}

extension ViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard !searchText.isEmpty else {
			updateSnapshot(with: [])
			return
		}
		
		debounceSearch(query: searchText)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	private func debounceSearch(query: String) {
		debounceTask?.cancel()
		debounceTask = Task<Void, Never> {
			[weak self] in
			
			do {
				try await Task.sleep(nanoseconds: 300_000_000_0)
				await self?.performSearch(query: query)
			} catch {
				print("Error: " + error.localizedDescription)
			}
		}
	}
	
	private func performSearch(query: String) async {
		guard !Task.isCancelled else { return }
		
		startSpinning()
		do {
			let filteredResults = try await NetworkController.shared.fetchSearchResults(query: query).results
			stopSpinning()
			updateSnapshot(with: filteredResults)
		} catch {
			stopSpinning()
			print("Error fetching search results: \(error.localizedDescription)")
			updateSnapshot(with: [])
		}
	}
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		dataSource.snapshot().numberOfItems
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let result = dataSource.itemIdentifier(for: indexPath) else {
			fatalError("Attempted to dequeue a cell for an unknown index path")
		}
		
		return dataSource.tableView(tableView, cellForRowAt: indexPath)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) else {
			print("Error: Unable to get the cell at indexPath \(indexPath)")
			return
		}
		
		let id = cell.searchID
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
			print("Error: Could not instantiate DetailViewController")
			return
		}
		
		print(id)
		detailVC.id = id
			navigationController?.pushViewController(detailVC, animated: true)
	}
}
