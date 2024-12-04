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

struct StoreItem: Codable {
	var wrapper: String
	var mediaType: String
	var artist: String
	var name: String
	var artworkMedium: URL
	var artworkLarge: URL
	var price: Double?
	var releaseDate: Date
	var isExplict: Bool
	
	var description: String {
"""
\(name) by \(artist)
This is \(isExplict ? "explicit" : "clean") piece of art
\(name) came out on \(releaseDate.formatted(date: .long, time: .omitted))
It will cost you $\(price ?? 0) to buy this.
"""
	}
	
	enum CodingKeys: String, CodingKey {
		case wrapper = "wrapperType"
		case mediaType = "kind"
		case artist = "artistName"
		case name = "trackName"
		case artworkMedium = "artworkUrl60"
		case artworkLarge = "artworkUrl100"
		case price = "trackPrice"
		case releaseDate
		case isExplict = "trackExplicitness"
	}
	
	init(from decoder: Decoder) throws {
		let containter = try decoder.container(keyedBy: CodingKeys.self)
		let explicitRawValue = try containter.decode(String.self, forKey: .isExplict)
		let releaseDateRawValue = try containter.decode(String.self, forKey: .releaseDate)
		
		let dateFormatter: DateFormatter = .init()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		self.releaseDate = dateFormatter.date(from: releaseDateRawValue)!
		
		
		
		switch explicitRawValue {
			case "explicit":
				self.isExplict = true
			default:
				self.isExplict = false
		}
		
		self.price = try containter.decodeIfPresent(Double.self, forKey: .price)
		self.artist = try containter.decode(String.self, forKey: .artist)
		self.name = try containter.decode(String.self, forKey: .name)
		self.artworkLarge = try containter.decode(URL.self, forKey: .artworkLarge)
		self.artworkMedium = try containter.decode(URL.self, forKey: .artworkMedium)
		self.wrapper = try containter.decode(String.self, forKey: .wrapper)
		self.mediaType = try containter.decode(String.self, forKey: .mediaType)
	}
}

struct SearchResponse: Codable { let results: [StoreItem] }


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
func getQuery(term: String, country: String = "US", media: String = "music", entity: String = "song", limit: Int = 50)
-> [String: String]
{
  [
    "term" : term,
    "country" : country,
    "media" : media,
    "entity" : entity,
	"limit" : String(limit)
  ]
}
Task {
	do {
		let davidBowieResults = try await fetchItems(matching: getQuery(term: "teenage wildlife david bowie", limit: 1))
		for davidBowieResult in davidBowieResults {
			print(davidBowieResult.description)
			print("---")
		}
		
		print()
		
		let weyesBloodResults = try await fetchItems(matching: getQuery(term: "andromeda weyes blood", limit: 1))
		for weyesBloodResult in weyesBloodResults {
			print(weyesBloodResult.description)
			print("---")
		}
		
		print()
		
		let mamboSunResults = try await fetchItems(matching: getQuery(term: "Mambo Sun T.Rex", limit: 1))
		for mamboSunResult in mamboSunResults {
			print(mamboSunResult.description)
			print("---")
		}
		
		print()
		
		let janisJoplinResults = try await fetchItems(matching: getQuery(term: "Cry Baby Janis Joplin", limit: 1))
		for janisJoplinResult in janisJoplinResults {
			print(janisJoplinResult.description)
			print("---")
		}
		
		print()
		
		let pinkResults = try await fetchItems(matching: getQuery(term: "Pink Pony Club", limit: 1))
		for pinkResult in pinkResults {
			print(pinkResult.description)
			print("---")
		}
	} catch {
		print(error)
	}
}
