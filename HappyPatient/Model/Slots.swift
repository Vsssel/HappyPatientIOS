//
//  Slots.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 08.12.2024.
//

import Foundation

struct Slots: Codable {
    let freeSlots: [FreeSLots]
    let priceList: [PriceList]
}

struct FreeSLots: Codable, Equatable {
    let startTime: String
    let endTime: String
}
