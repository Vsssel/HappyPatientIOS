//
//  AppointmentDetail.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 15.12.2024.
//

import Foundation

struct AppointmentDetail: Codable {
    let id: Int
    let date: String
    let index: Int
    let startTime: String
    let endTime: String
    let price: Int
    let status: String
    let type: Type
    let category: Category
    let room: Room
    let doctor: DoctorInfo
    let patient: Patient
    let receipt: Receipt?
    let medicalRecords: [MedicalRecords]?
}

struct Patient: Codable {
    let id: Int
    let name: String
    let surname: String
}

struct Receipt: Codable {
    let id: Int
    let timestamp: String
    let method: String
    let provider: String
    let amount: Int
}

struct MedicalRecords: Codable {
    let title: String
    let type: String
    let addedTime: String
    let content: String
}
