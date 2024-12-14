//
//  AppointmentsViewModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 15.12.2024.
//

import Foundation
import Combine

class AppointmentsViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var appointments: [Appointment]?

    private var cancellables: Set<AnyCancellable> = []

    func getAppointments() {
        isLoading = true
        errorMessage = nil
        let isAuth = AuthenticationManager.shared.isAuth()

        NetworkManager.shared.request("/patient/appointments",
                                      method: .get,
                                      auth: isAuth,
                                      responseType: [Appointment].self)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] appointments in
                self?.appointments = appointments
            })
            .store(in: &cancellables)
    }
    
    
    func deleteAppointment(id: Int, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let isAuth = AuthenticationManager.shared.isAuth()
        
        NetworkManager.shared.request("/patient/appointments/\(id)",
                                      method: .delete,
                                      auth: isAuth,
                                      responseType: AppointmentResponse.self)
            .sink(receiveCompletion: { [weak self] completionResult in
                self?.isLoading = false
                switch completionResult {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                completion(true)
            })
            .store(in: &cancellables)
    }

}
