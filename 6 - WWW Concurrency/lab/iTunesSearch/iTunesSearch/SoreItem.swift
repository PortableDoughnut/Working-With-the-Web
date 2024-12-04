//
//  SoreItem.swift
//  iTunesSearch
//
//  Created by Gwen Thelin on 12/4/24.
//

import UIKit

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
