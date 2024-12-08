//
//  File.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 02.12.2024.
//

import Foundation

struct Doctor: Codable {
    let id: Int
    let name: String
    let surname: String
    let avatarUrl: String
    let age: Int
    let expInMonthes: Int
    let category: Category
    let office: Office
    let priceList: [PriceList]
    let experience: [Experience]
    let education: [Education]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case surname
        case avatarUrl
        case age
        case expInMonthes
        case category
        case office
        case priceList = "price_list"
        case experience
        case education
    }
}

struct Category: Codable {
    let id: Int
    let title: String
}

struct Office: Codable {
    let id: Int
    let buildingId: Int
    let address: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case buildingId = "building_id"
        case address
        case title
    }
}

struct PriceList: Codable {
    let typeId: Int
    let typeName: String
    let price: Int
}

struct Experience: Codable {
    let id: Int
    let organization: String
    let startDate: String
    let endDate: String
    let position: String
    let hoursAtDay: Int
}

struct Education: Codable {
    let id: Int
    let organization: String
    let startYear: Int
    let endYear: Int
    let gpa: Int
    let gpaFrom: Int
}
