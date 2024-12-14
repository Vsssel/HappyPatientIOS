//
//  Appointments.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 15.12.2024.
//

import Foundation

struct Appointment: Codable {
    let id: Int
    let index: Int
    let date: String
    let startTime: String
    let endTime: String
    let price: Int
    let isFinished: Bool
    let isPaid: Bool
    let type: Type
    let category: Category
    let room: Room
    let doctor: DoctorInfo
}

struct Type: Codable {
    let id: Int
    let name: String
}

struct Room: Codable {
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

struct DoctorInfo: Codable {
    let id: Int
    let name: String
    let surname: String
    let avatarUrl: String
}
