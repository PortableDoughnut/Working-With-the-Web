//
//  NetworkController.swift
//  Life-FormSerch
//
//  Created by Gwen Thelin on 12/20/24.
//

import Foundation

class NetworkController {
	static let shared = NetworkController()
	
	func fetchSearchResults(query: String) async throws -> SearchResult? {
		var urlComponents: URLComponents = URLComponents(string: "https://eol.org/api/search/1.0.json")!
		urlComponents.queryItems = [ .init(name: "q", value: query) ]
		let url = urlComponents.url!
		
		let (data, response) = try await URLSession.shared.data(from: url)
			
			guard let httpResponse = response as? HTTPURLResponse,
				  httpResponse.statusCode == 200
			else {
				print("invalid response from server")
				return nil
			}
			
		let toReturn =  try await getMyTypeFromUrl(type: SearchResult.self, url: url)
		print(toReturn)
		return toReturn
	}
	
	func getMyTypeFromUrl<T: Decodable>(type: T.Type, url: URL) async throws -> T {
		let (data, _) = try await URLSession.shared.data(from: url)
		return try JSONDecoder().decode(T.self, from: data)
	}
}
