import UIKit

enum JSONSerializationError: Error {
	case invalidJSON
}

extension JSONSerializationError: CustomStringConvertible {
	var description: String {
		let errorString: String = "Error:"
		var errorMessage: String
		
		switch self {
			case .invalidJSON: errorMessage =  "Invalid JSON"
		}
		
		return "\(errorString) \(errorMessage)"
	}
}

extension Data {
	func printPrettyJSON() throws {
		guard
			let jsonObject: Any = try? JSONSerialization.jsonObject(with: self, options: []),
			let jsonData: Data = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
			let jsonString: String = String(data: jsonData, encoding: .utf16)
		else {
			throw JSONSerializationError.invalidJSON
		}
		
		print(jsonData)
	}
}

struct StoreItem: Codable {
	var wrapper: String
	var mediaType: String
	var artist: String
	var name: String
	var artworkMedium: URL
	var artworkLarge: URL
	var price: Double
	var releaseDate: Date
	var isExplict: Bool
	
	enum CodingKeys: String, CodingKey {
		case wrapper = "wrapperType"
		case mediaType = "kind"
		case artist = "artistName"
		case name = "trackName"
		case artworkMedium = "artworkUrl60"
		case artworkLarge = "artworkUrl100"
		case price = "trackPrice"
		case releaseDate
		case isExplict = "trackExplictness"
	}
	
	init(from decoder: Decoder) throws {
		let containter = try decoder.container(keyedBy: CodingKeys.self)
		let rawValue = try containter.decode(String.self, forKey: .isExplict)
		
		switch rawValue {
			case "explicit":
				self.isExplict = true
			default:
				self.isExplict = false
		}
		
		self.artist = try containter.decode(String.self, forKey: .artist)
		self.name = try containter.decode(String.self, forKey: .name)
		self.releaseDate = try containter.decode(Date.self, forKey: .releaseDate)
		self.artworkLarge = try containter.decode(URL.self, forKey: .artworkLarge)
		self.artworkMedium = try containter.decode(URL.self, forKey: .artworkMedium)
		self.price = try containter.decode(Double.self, forKey: .price)
		self.wrapper = try containter.decode(String.self, forKey: .wrapper)
		self.mediaType = try containter.decode(String.self, forKey: .mediaType)
	}
}

struct SearchResponse: Codable {
	let results: [StoreItem]
}

var iTunesSearchURLComponents: URLComponents = .init()
iTunesSearchURLComponents.scheme = "https"
iTunesSearchURLComponents.host = "itunes.apple.com"
iTunesSearchURLComponents.path = "/search"

/// Makes a URLQueryItem array for use in searching iTunes content
/// - Parameters:
///   - term: The URL-encoded text string you want to search for. For example: jack+johnson.
///   - country: The two-letter country code for the store you want to search. The search uses the default store front for the specified country. For example: US. The default is US.
///   - media: The media type you want to search for. For example: movie. The default is all.
///   - entity: The type of results you want returned, relative to the specified media type. For example: movieArtist for a movie media type search. The default is the track entity associated with the specified media type.
///   - limit: The number of search results you want the iTunes Store to return. For example: 25. The default is 50.
/// - Returns: The URLQuearyItem array
func getQuery(term: String, country: String, media: String, entity: String, limit: Int)
  -> [URLQueryItem]
{
  [
    URLQueryItem(name: "term", value: term),
    URLQueryItem(name: "country", value: country),
    URLQueryItem(name: "media", value: media),
    URLQueryItem(name: "entity", value: entity),
    URLQueryItem(name: "limit", value: String(limit)),
  ]
}

@MainActor func iTunesSearch(
	term: String, country: String, media: String, entity: String, limit: Int) {
		iTunesSearchURLComponents.queryItems = getQuery(
			term: term,
			country: country,
			media: media,
			entity: entity,
			limit: limit
		)
		
		guard let iTunesSearchURL = iTunesSearchURLComponents.url else {
			print("Error: Could not create iTunesSearchURL")
			return
		}
		
		Task {
			do {
				let (data, response) = try await URLSession.shared.data(from: iTunesSearchURL)
				
				guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
					do { try data.printPrettyJSON() }
					catch { print(error) }
					throw URLError(.badServerResponse)
				}
				
//				let iTunesResponse = try JSONDecoder().decode(iTunesSearchResponse.self, from: data)
				
//				var iTunesItems: [iTunesSearchResults] = iTunesResponse.results
				
				/*
				for item in iTunesItems {
					print(item)
				}
				*/
			} catch {
				print(error)
			}
		}
	}

iTunesSearch(
  term: "teenage wildlife david bowie", country: "us", media: "song", entity: "musicTrack", limit: 1
)
iTunesSearch(
  term: "Andromeda Weyes Blood", country: "us", media: "song", entity: "musicTrack", limit: 1)
iTunesSearch(term: "Mambo Sun T.Rex", country: "us", media: "song", entity: "musicTrack", limit: 1)
iTunesSearch(
  term: "Cry Baby Janis Joplin", country: "us", media: "song", entity: "musicTrack", limit: 1)
iTunesSearch(term: "Pink Pony Club", country: "us", media: "song", entity: "musicTrack", limit: 1)
