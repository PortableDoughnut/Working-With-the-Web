//
//  StoreItemController.swift
//  iTunesSearch
//
//  Created by Gwen Thelin on 12/4/24.
//

import UIKit

enum JSONSerializationError: Error {
	case invalidJSON
}

extension JSONSerializationError: CustomStringConvertible {
	var description: String {
		switch self {
			case .invalidJSON: return "Invalid JSON"
		}
	}
}

enum FetchError: Error, LocalizedError, CustomStringConvertible {
	var description: String {
		switch self {
			case .invalidURL: return "Invalid URL"
			case .invalidResponse: return "Invalid response"
			case .invalidData: return "Invalid data"
		}
	}
	
	case invalidURL
	case invalidResponse
	case invalidData
}

extension Data {
	func printPrettyJSON() throws {
		guard
			let jsonObject: Any = try? JSONSerialization.jsonObject(with: self, options: []),
			let jsonData: Data = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
			let jsonString: String = String(data: jsonData, encoding: .utf8)
		else {
			throw JSONSerializationError.invalidJSON
		}
		
		print(jsonString)
	}
}

func fetchItems(matching query: [String: String]) async throws -> [StoreItem] {
	var iTunesSearchURLComponents: URLComponents = .init()
	iTunesSearchURLComponents.scheme = "https"
	iTunesSearchURLComponents.host = "itunes.apple.com"
	iTunesSearchURLComponents.path = "/search"
	
	iTunesSearchURLComponents.queryItems = query.map {
		URLQueryItem(name: $0.key, value: $0.value)
	}
	
	do {
		let (data, response) = try await URLSession.shared.data(from: iTunesSearchURLComponents.url!)
		guard let httpResponse = response as? HTTPURLResponse,
			  httpResponse.statusCode == 200
		else {
			throw FetchError.invalidResponse
		}
		let decoder = JSONDecoder()
		let searchResponse = try decoder.decode(SearchResponse.self, from: data)
		return searchResponse.results
	} catch {
		print("Error fetching items: \(error)")
		throw error
	}
}
