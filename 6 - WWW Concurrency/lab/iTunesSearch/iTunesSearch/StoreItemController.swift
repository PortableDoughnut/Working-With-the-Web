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
      let jsonData: Data = try? JSONSerialization.data(
        withJSONObject: jsonObject, options: [.prettyPrinted]),
      let jsonString: String = String(data: jsonData, encoding: .utf8)
    else {
      throw JSONSerializationError.invalidJSON
    }

    print(jsonString)
  }
}

class StoreItemController {

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

  /// Makes a URLQueryItem array for use in searching iTunes content
  /// - Parameters:
  ///   - term: The URL-encoded text string you want to search for. For example: jack+johnson.
  ///   - country: The two-letter country code for the store you want to search. The search uses the default store front for the specified country. For example: US. The default is US.
  ///   - media: The media type you want to search for. For example: movie. The default is all.
  ///   - entity: The type of results you want returned, relative to the specified media type. For example: movieArtist for a movie media type search. The default is the track entity associated with the specified media type.
  ///   - limit: The number of search results you want the iTunes Store to return. For example: 25. The default is 50.
  /// - Returns: The URLQuearyItem array
  func getQuery(
    term: String, country: String = "US", media: String = "music", entity: String = "song",
    limit: Int = 50
  )
    -> [String: String]
  {
    [
      "term": term,
      "country": country,
      "media": media,
      "entity": entity,
      "limit": String(limit),
    ]
  }
}
