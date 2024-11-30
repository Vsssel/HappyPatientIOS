//
//  LoginModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 29.11.2024.
//

import Foundation
import Combine
import Alamofire

struct User: Codable {
    let id: Int
    let name: String
    let surname: String
    let gender: String
    let birthDate: String
    let age: Int
    let email: String
    let iin: String
    let role: String
}
