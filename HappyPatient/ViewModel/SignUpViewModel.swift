//
//  SignUpViewModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 29.11.2024.
//

import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var emailSent: Bool? = false
    
    public var cancellables: Set<AnyCancellable> = []
    
    private let baseURL = "http://64.225.71.203:3000"

    func emailVerification(email: String, iin: String) {
        isLoading = true
        errorMessage = nil

        let parameters: [String: Any] = [
            "email": email,
            "iin": iin
        ]

        NetworkManager.shared.request("/patient/auth", method: .post, parameters: parameters, responseType: AuthResponse.self)
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
                if authResponse.success {
                    self?.emailSent = true
                } else {
                    self?.errorMessage = authResponse.message
                }
            }
            .store(in: &cancellables)
    }
}
