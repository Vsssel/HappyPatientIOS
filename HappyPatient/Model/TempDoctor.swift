//
//  File.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 16.12.2024.
//

import Foundation

struct TempDoctor: Decodable {
    let id: Int
    let name: String
    let surname: String
    let avatarUrl: String
    let age: Int
    let expInMonthes: Int
    let category: Category
    let office: Office
}
