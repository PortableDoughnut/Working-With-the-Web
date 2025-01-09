//
//  TaxonomySourceTableViewCell.swift
//  Life-FormSerch
//
//  Created by Gwen Thelin on 12/20/24.
//

import UIKit

class TaxonomySourceTableViewCell: UITableViewCell {
	@IBOutlet weak var detailLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		
        // Configure the view for the selected state
    }
	
	
	func configure(with taxonomySource: EOLDetail) {
		print(taxonomySource.taxonConcept.taxonConcepts?.first?.nameAccordingTo)
		detailLabel.text = taxonomySource.taxonConcept.taxonConcepts?.first?.nameAccordingTo
	}
	
}
