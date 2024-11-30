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

        NetworkManager.shared.request("/auth",
                                      method: .post,
                                      parameters: parameters,
                                      auth: false,
                                      responseType: User.self)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] user in
                self?.user = user
            })
            .store(in: &cancellables)
    }
}
