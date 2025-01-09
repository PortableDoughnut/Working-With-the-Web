//
//  DetailViewController.swift
//  Life-FormSerch
//
//  Created by Gwen Thelin on 12/20/24.
//

import UIKit

class DetailViewController: UIViewController {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var creditLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var linkButton: UIButton!
	
	var id: Int?
	var taxonomy: EOLDetail?
	var taxonomyURL: URL?
	let networkController: NetworkController = .init()
	
	private let placeholderImage = UIImage(systemName: "exclamationmark.triangle.fill")
	private let activityIndicator = UIActivityIndicatorView(style: .large)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self
		imageView.image = placeholderImage
		
		activityIndicator.center = view.center
		activityIndicator.hidesWhenStopped = true
		view.addSubview(activityIndicator)
		activityIndicator.startAnimating()
		
		guard let id = id else {
			print("ID is nil")
			activityIndicator.stopAnimating()
			activityIndicator.removeFromSuperview()
			return
		}
		
		Task {
			do {
				taxonomy = try await networkController.fetchTaxon(id: id)
				
				guard let taxonomy = taxonomy else {
					print("Failed to fetch taxonomy")
					DispatchQueue.main.async {
						self.activityIndicator.stopAnimating()
						self.activityIndicator.removeFromSuperview()
					}
					return
				}
				
				var imageURLString: String? = taxonomy.getMediaURL()
				imageURLString = imageURLString ?? "https://icon-library.com/images/missing-photo-icon/missing-photo-icon-5.jpg"
				
				print("Using image URL: \(imageURLString!)")
				
				if let imageURL = URL(string: imageURLString!) {
					fetchImage(from: imageURL) { [weak self] image in
						DispatchQueue.main.async {
							if let image = image {
								self?.imageView.image = image
							} else {
								print("Failed to load image")
								self?.imageView.image = self?.placeholderImage
							}
							self?.creditLabel.text = taxonomy.getImageCredit()
							
							self?.taxonomyURL = URL(string: taxonomy.getImageLicense() ?? "about:blank")
							self?.linkButton.isEnabled = taxonomy.getImageLicense() != nil
						}
					}
				} else {
					print("No valid image URL")
					DispatchQueue.main.async {
						self.imageView.image = self.placeholderImage
					}
				}
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.activityIndicator.stopAnimating()
					self.activityIndicator.removeFromSuperview()
				}
			} catch {
				print("Failed to fetch taxonomy for id \(id): \(error)")
				DispatchQueue.main.async {
					self.activityIndicator.stopAnimating()
					self.activityIndicator.removeFromSuperview()
					self.displayErrorAlert(message: "Failed to fetch details.")
				}
			}
		}
	}
	
	@IBAction func linkButtonPressed(_ sender: UIButton) {
		UIApplication.shared.open(taxonomyURL!, options: [:], completionHandler: nil)
	}
	
	private func displayErrorAlert(message: String) {
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		self.present(alert, animated: true)
	}
	
	func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
		URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				print("Error fetching image: \(error)")
				completion(nil)
				return
			}
			
			guard let data = data, let image = UIImage(data: data) else {
				print("Invalid image data")
				completion(nil)
				return
			}
			
			DispatchQueue.main.async {
				completion(image)
			}
		}.resume()
	}
		
		
		/*
		 // MARK: - Navigation
		 
		 // In a storyboard-based application, you will often want to do a little preparation before navigation
		 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		 // Get the new view controller using segue.destination.
		 // Pass the selected object to the new view controller.
		 }
		 */
		
	}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if taxonomy != nil {
			switch indexPath.row {
				case 0:
					if let cell = tableView.dequeueReusableCell(withIdentifier: "TaxonomySourceCell", for: indexPath) as? TaxonomySourceTableViewCell {
						cell.configure(with: taxonomy!)
						return cell
					}
				case 1:
					if let cell = tableView.dequeueReusableCell(withIdentifier: "ScientificNameCell", for: indexPath) as? ScientificNameTableViewCell {
						cell.configure(with: taxonomy!)
						return cell
					}
				default:
					break
			}
		}
		
		return UITableViewCell()
	}
}
