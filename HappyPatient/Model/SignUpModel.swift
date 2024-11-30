//
//  SignUpModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 29.11.2024.
//

import Foundation

struct TempUserInfo {
    let name: String
    let surname: String
    let email: String
    let iin: String
}

struct EmailConfirmationRequest: Codable {
    let email: String
    let iin: String
}

struct EmailConfirmationResponse: Codable {
    let detail: String
}

struct SignUpRequest: Codable {
    let name: String
    let surname: String
    let email: String
    let iin: String
    let gender: String
    let birthDate: String
    let emailVerificationCode: Int
    let password: String
}


struct SignUpResponse: Codable {
    let id: Int
}
