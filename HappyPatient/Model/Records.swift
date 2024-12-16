//
//  File.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 15.12.2024.
//

import Foundation
import UIKit

struct Record: Codable {
    let start: Int
    let end: Int
    let total: Int
    let page: [Page]
}


struct Page: Codable {
    let type: String
    let title: String
    let content: String
    let addedTime: String
    let doctor: DoctorInfo
    let appointment: AppointmentInfo
}

struct AppointmentInfo: Codable {
    let id: Int
    let date: String
    let startTime: String
    let endTime: String
    let type: Type
    let category: Category
}
