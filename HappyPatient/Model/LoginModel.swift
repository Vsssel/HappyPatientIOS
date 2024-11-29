//
//  LoginModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 29.11.2024.
//

import Foundation
import Combine
import Alamofire

struct User: Decodable {
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

struct ValidationError: Decodable {
    let detail: [ValidationDetail]
}

struct ValidationDetail: Decodable {
    let loc: [String] // or `[Any]` if the `loc` array contains mixed types
    let msg: String
    let type: String
}

struct AuthResponse: Decodable {
    let success: Bool
    let data: User?
    let message: String?
}
