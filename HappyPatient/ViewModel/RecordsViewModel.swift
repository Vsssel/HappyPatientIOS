//
//  RecordsViewModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 15.12.2024.
//

import Foundation
import Combine

class RecordsViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var records: Record?

    private var cancellables: Set<AnyCancellable> = []

    func getRecords(recordType: String, offset: Int = 0, limit: Int = 100) {
        isLoading = true
        errorMessage = nil
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "record_type", value: recordType),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))        ]
        
        NetworkManager.shared.request("/patient/medical-records",
                                      method: .get,
                                      queryItems: queryItems,
                                      auth: true,
                                      responseType: Record.self)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] records in
                self?.records = records
            })
            .store(in: &cancellables)
    }

}
