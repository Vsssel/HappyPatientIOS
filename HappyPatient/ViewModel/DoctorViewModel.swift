//
//  DoctorViewModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 02.12.2024.
//

import Foundation
import Combine

class DoctorViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var doctor: Doctor?

    private var cancellables: Set<AnyCancellable> = []

    func getDoctor(id: Int) {
        isLoading = true
        errorMessage = nil
        let isAuth = AuthenticationManager.shared.isAuth()

        let parameters: [String: Any] = [
            "id": id
        ]

        NetworkManager.shared.request("/patient/doctors/\(id)",
                                      method: .get,
                                      auth: isAuth,
                                      responseType: Doctor.self)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] doctor in
                self?.doctor = doctor
            })
            .store(in: &cancellables)
    }
}

