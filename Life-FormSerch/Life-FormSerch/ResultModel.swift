//
//  ResultModel.swift
//  Life-FormSerch
//
//  Created by Gwen Thelin on 1/6/25.
//

import Foundation

struct EOLDetail: Decodable {
	let taxonConcept: TaxonConcept
	
	struct TaxonConcept: Decodable {
		let identifier: Int
		let scientificName: String
		let richnessScore: Double?
		let taxonConcepts: [TaxonConceptDetails]?
		let dataObjects: [DataObject]?
	}
	
	struct TaxonConceptDetails: Decodable {
		let identifier: Int
		let scientificName: String
		let name: String
		let nameAccordingTo: String
		let canonicalForm: String
		let sourceIdentifier: String
		let taxonRank: String?
	}
	
	struct DataObject: Decodable {
		let mediaURL: String
		let license: String?
		let rightsHolder: String?
		let agents: [Agent]?
	}
	
	struct Agent: Decodable {
		let full_name: String?
		let role: String?
	}
	
	func getMediaURL() -> String? {
		return taxonConcept.dataObjects?.first?.mediaURL
	}
	
	func getTaxonomySources() -> [String]? {
		return taxonConcept.taxonConcepts?.map { $0.nameAccordingTo }
	}
	
	func getImageLicense() -> String? {
		return taxonConcept.dataObjects?.first?.license
	}
	
	func getImageRightsHolder() -> String? {
		return taxonConcept.dataObjects?.first?.rightsHolder
	}
	
	func getImageCredit() -> String? {
		if let agents = taxonConcept.dataObjects?.first?.agents {
			for agent in agents {
				if agent.role?.lowercased() == "photographer" {
					return agent.full_name
				}
			}
		}
		return nil
	}
}
