//
//  NetworkController.swift
//  Life-FormSerch
//
//  Created by Gwen Thelin on 12/20/24.
//

import Foundation

class NetworkController {
	static let shared = NetworkController()
	
	func fetchSearchResults(query: String) async throws -> SearchResult {
		var urlComponents = URLComponents(string: "https://eol.org/api/search/1.0.json")
		urlComponents?.queryItems = [URLQueryItem(name: "q", value: query)]
		
		guard let url = urlComponents?.url else {
			throw URLError(.badURL)
		}
		
		let (data, response) = try await URLSession.shared.data(from: url)
		guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
			throw URLError(.badServerResponse)
		}
		
		return try JSONDecoder().decode(SearchResult.self, from: data)
	}
	
	func fetchTaxon(id: Int) async throws -> EOLDetail {
		guard let url = URL(string: "https://eol.org/api/pages/1.0/\(id).json?taxonomy=true&images_per_page=1&language=en") else {
			throw URLError(.badURL)
		}
		
		let (data, response) = try await URLSession.shared.data(from: url)
		guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
			throw URLError(.badServerResponse)
		}
		
		let dataString = String(data: data, encoding: .utf8)
		
		print(dataString)
		
		return try JSONDecoder().decode(EOLDetail.self, from: data)
	}
}
