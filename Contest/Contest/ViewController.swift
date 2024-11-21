//
//  ViewController.swift
//  Contest
//
//  Created by Gwen Thelin on 11/21/24.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var emailTextField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	@IBAction func emailSubmitButtonPressed(_ sender: UIButton) {
		if emailTextField.text?.isEmpty == true ||
			emailTextField.text?.contains(/[:word:]@[:alpha:].[:alpha:]/) == false {
			emailTextField.placeholder = "Please enter your email address."
			
			UIView.animate(withDuration: 0.1, animations: {
				//				self.emailTextField.transform = CGAffineTransform(scaleX: , y:  dropleぽ)
				self.emailTextField.transform = CGAffineTransform(rotationAngle: -0.0125)
			}) { _ in
				UIView.animate(withDuration: 0.1, animations: {
					self.emailTextField.transform = CGAffineTransform(rotationAngle: 0.0125)
				}) { _ in
					UIView.animate(withDuration: 0.1, animations: {
						self.emailTextField.transform = CGAffineTransform.identity
					})
				}
			}
		}
		else {
			performSegue(withIdentifier: "EmailEnteredSegue", sender: nil)
		}
	}
	
}
