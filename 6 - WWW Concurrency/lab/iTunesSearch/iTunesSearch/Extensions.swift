//
//  extensions.swift
//  iTunesSearch
//
//  Created by Gwen Thelin on 12/6/24.
//

import UIKit

extension URL {
  var urlToImage: UIImage {
	guard let data = try? Data(contentsOf: self)
	else { return UIImage.init(systemName: "exclamationmark.triangle.fill")! }

	return .init(data: data) ?? UIImage.init(systemName: "exclamationmark.triangle.fill")!
  }
}
