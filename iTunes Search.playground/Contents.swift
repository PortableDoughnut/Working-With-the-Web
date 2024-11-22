import UIKit

struct iTunesSearchResponse: Decodable {
	let results: [iTunesSearchResults]
}

struct iTunesSearchResults: Decodable {
	let artistName: String?
	let trackName: String?
}

extension iTunesSearchResults: CustomStringConvertible {
	var description: String {
		"\(artistName ?? "Artist Name") - \(trackName ?? "Track Name")"
	}
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
func getQuery
(term: String, country: String, media: String, entity: String, limit: Int)
-> [URLQueryItem] {
	[
		URLQueryItem(name: "term", value: term),
		URLQueryItem(name: "country", value: country),
		URLQueryItem(name: "media", value: media),
		URLQueryItem(name: "entity", value: entity),
		URLQueryItem(name: "limit", value: String(limit))
	]
}

@MainActor func iTunesSearch(term: String, country: String, media: String, entity: String, limit: Int) {
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
				print("Error: Bad HTTP response")
				throw URLError(.badServerResponse)
			}
			
			let iTunesResponse = try JSONDecoder().decode(iTunesSearchResponse.self, from: data)
			
			var iTunesItems: [iTunesSearchResults] = iTunesResponse.results
			
			for item in iTunesItems {
				print(item)
			}
		} catch {
			print("Error: \(error.localizedDescription)")
		}
	}
}

iTunesSearch(term: "teenage wildlife david bowie", country: "us", media: "song", entity: "musicTrack", limit: 1)
iTunesSearch(term: "Andromeda Weyes Blood", country: "us", media: "song", entity: "musicTrack", limit: 1)
iTunesSearch(term: "Mambo Sun T.Rex", country: "us", media: "song", entity: "musicTrack", limit: 1)
iTunesSearch(term: "Cry Baby Janis Joplin", country: "us", media: "song", entity: "musicTrack", limit: 1)
iTunesSearch(term: "Pink Pony Club", country: "us", media: "song", entity: "musicTrack", limit: 1)
