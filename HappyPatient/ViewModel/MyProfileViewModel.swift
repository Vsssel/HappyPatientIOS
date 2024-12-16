//
//  MyProfileViewModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 15.12.2024.
//

import Foundation
import Combine

class MyProfileViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var user: User?

    private var cancellables: Set<AnyCancellable> = []

    func getUser() {
        isLoading = true
        errorMessage = nil
        let isAuth = AuthenticationManager.shared.isAuth()

        NetworkManager.shared.request("/patient/auth",
                                      method: .get,
                                      auth: isAuth,
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

