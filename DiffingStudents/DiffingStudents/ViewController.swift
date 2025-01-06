//
//  ViewController.swift
//  DiffingStudents
//
//  Created by Gwen Thelin on 12/13/24.
//

import UIKit

class ViewController: UIViewController {
	enum Section: CaseIterable {
		case students
		case teachers
	}
	
	struct Person: Hashable {
		let id: UUID = .init()
		let name: String
		let isTeacher: Bool
	}
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	private var dataSource: UITableViewDiffableDataSource<Section, Person>!
	private var teachers: [Person] = [
		Person(name:"Jane", isTeacher: true), Person(name:"Ryan", isTeacher: true), Person(name:"Nathan", isTeacher: true), Person(name:"Parker", isTeacher: true), Person(name:"Mike", isTeacher: true), Person(name:"Rod", isTeacher: true)
	]
	private var students:[Person] = [
		Person(name: "Gwen", isTeacher: false), Person(name: "Kevin", isTeacher: false), Person(name: "Nash", isTeacher: false), Person(name: "Kaden", isTeacher: false), Person(name: "Wesley", isTeacher: false), Person(name: "Skylar", isTeacher: false)
	]
	
	private var filteredTeachers: [Person] = []
	private var filteredStudents: [Person] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupDataSource()
		setupSearchBar()
		applyInitalSnapsot()
	}
	
	func setupSearchBar() {
		searchBar.delegate = self
		filteredTeachers = teachers
		filteredStudents = students
	}
	
	func setupDataSource() {
		dataSource = UITableViewDiffableDataSource<Section, Person>(tableView: tableView, cellProvider: {
			tableView, indexPath, person in
			let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
			cell.textLabel?.text = person.name
			cell.detailTextLabel?.text = person.isTeacher ? "Teacher" : "Student"
			return cell
		})
	}
	
	func applyShapshot(with searchText: String = "") {
		var snapshot = NSDiffableDataSourceSnapshot<Section, Person>()
		
		if snapshot.sectionIdentifiers.isEmpty {
			snapshot.appendSections(Section.allCases)
		}
		
		switch searchText.isEmpty {
			case true:
				filteredStudents = students
				filteredTeachers = teachers
			case false:
				filteredStudents = students.filter {
					$0.name.lowercased().contains(searchText.lowercased())
				}
				filteredTeachers = teachers.filter {
					$0.name.lowercased().contains(searchText.lowercased())
				}
		}
		
		snapshot.appendItems(filteredTeachers, toSection: .teachers)
		snapshot.appendItems(filteredStudents, toSection: .students)
		dataSource.apply(snapshot, animatingDifferences: true)
	}
	
	func applyInitalSnapsot() {
		applyShapshot()
	}
}

extension ViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		applyShapshot(with: searchText)
	}
}
