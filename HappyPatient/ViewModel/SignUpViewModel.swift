//
//  SignUpViewModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 29.11.2024.
//

import Combine
import Foundation

class SignUpViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var emailSent: Bool = false
    @Published var signedUp: Bool = false
    
    public var cancellables: Set<AnyCancellable> = []
    
    func emailVerification(email: String, iin: String) {
        isLoading = true
        errorMessage = nil

        let parameters: [String: Any] = [
            "email": email,
            "iin": iin
        ]

        NetworkManager.shared.request("/patient/auth", method: .post, parameters: parameters, responseType: EmailConfirmationResponse.self)
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
                if authResponse.detail == "Verification Code is sent to your Email" {
                    self?.emailSent = true
                } else {
                    self?.errorMessage = "Error occurred"
                }
            }
            .store(in: &cancellables)
    }
    
    
    func signUp(params: SignUpRequest) {
        isLoading = true
        errorMessage = nil

        // Prepare parameters
        let parameters: [String: Any] = [
            "name": params.name,
            "surname": params.surname,
            "email": params.email,
            "iin": params.iin,
            "gender": params.gender,
            "birthDate": params.birthDate,
            "emailVerificationCode": params.emailVerificationCode,
            "password": params.password
        ]

        // Network request
        NetworkManager.shared.request(
            "/patient/auth/sign-up",
            method: .post,
            parameters: parameters,
            responseType: SignUpResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            switch completion {
            case .failure(let error):
                self?.errorMessage = error.asAFError?.errorDescription
            case .finished:
                break
            }
        } receiveValue: { [weak self] response in
            if response.id != 0 {
                self?.signedUp = true
            } else {
                self?.errorMessage = "An error occurred during sign-up."
            }
        }
        .store(in: &cancellables)
    }

}
