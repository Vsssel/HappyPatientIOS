//
//  LoginViewModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 29.11.2024.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var user: User?

    private var cancellables: Set<AnyCancellable> = []

    func login(username: String, password: String) {
        isLoading = true
        errorMessage = nil

        let parameters: [String: Any] = [
            "login": username,
            "password": password
        ]
        
        NetworkManager.shared.request("/patient/auth", method: .post, parameters: parameters, responseType: User.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            } receiveValue: { [weak self] authResponse in
                if authResponse.id != 0 {
                    self?.user = authResponse
                } else {
                    self?.errorMessage = "Error occured"
                }
            }
            .store(in: &cancellables) // Correctly stores the subscription
    }
}

