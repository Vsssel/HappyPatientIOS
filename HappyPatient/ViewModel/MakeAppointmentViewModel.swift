//
//  MakeAppointmentViewModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 08.12.2024.
//

import Foundation
import Combine

class MakeAppointmentViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var slots: Slots?

    private var cancellables: Set<AnyCancellable> = []

    func getFreeSlots(id: Int, date: String, except_slot_id: Int? = nil, duration: Int? = nil, min_interval: Int? = nil) {
        isLoading = true
        errorMessage = nil

        let isAuth = AuthenticationManager.shared.isAuth()

        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "date", value: date))
        if let exceptSlotId = except_slot_id {
            queryItems.append(URLQueryItem(name: "except_slot_id", value: "\(exceptSlotId)"))
        }
        if let duration = duration {
            queryItems.append(URLQueryItem(name: "duration", value: "\(duration)"))
        }
        if let minInterval = min_interval {
            queryItems.append(URLQueryItem(name: "min_interval", value: "\(minInterval)"))
        }

        var urlComponents = URLComponents()
        urlComponents.path = "/patient/doctors/\(id)/day/\(date)"
        urlComponents.queryItems = queryItems

        guard let urlString = urlComponents.url?.absoluteString else {
            self.errorMessage = "Failed to build URL"
            self.isLoading = false
            return
        }

        NetworkManager.shared.request(
            urlString,
            method: .get,
            auth: isAuth,
            responseType: Slots.self
        )
        .sink(receiveCompletion: { [weak self] completion in
            DispatchQueue.main.async {
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }, receiveValue: { [weak self] slots in
            print(slots)
            DispatchQueue.main.async {
                self?.slots = slots
            }
        })
        .store(in: &cancellables)
    }
    
    
    func postAppointment(doctorId: Int, date: String, typeId: Int, startsAt: String, endsAt: String) {
        isLoading = true
        errorMessage = nil

        let parameters: [String: Any] = [
            "doctorId": doctorId,
            "date": date,
            "typeId": typeId,
            "startsAt": startsAt,
            "endsAt": endsAt
        ]

        NetworkManager.shared.request("/patient/appointments", method: .post, parameters: parameters, auth: true, responseType: AppointmentResponse.self)
            .sink { completion in
                self.isLoading = false
                switch completion {
                case .finished:
                    print("Request finished successfully.")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Error creating appointment: \(self.errorMessage ?? "Unknown error")")
                }
            } receiveValue: { response in
                print("Appointment created successfully: \(response.detail)")
            }
            .store(in: &cancellables)
    }
}
