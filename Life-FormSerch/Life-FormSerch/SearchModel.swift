//
//  SearchModel.swift
//  Life-FormSerch
//
//  Created by Gwen Thelin on 12/20/24.
//

import Foundation

struct SearchResult: Codable {
	let totalResults: Int
	let startIndex: Int
	let itemsPerPage: Int
	let results: [Result]
}

struct Result: Codable, Hashable {
	let id: Int
	let title: String
	let link: String
	let content: String
}
