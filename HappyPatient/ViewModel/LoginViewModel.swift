//
//  LoginViewModel.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 29.11.2024.
//

import Foundation
import Combine
import Alamofire

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
        
        // Ensure the base URL is included
        let baseURL = "http://localhost:2222"  // Replace with the actual base URL
        let url = "\(baseURL)/auth"  // Complete URL for the request

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .validate() // Optional: Validate response status code
            .responseDecodable(of: User.self) { [weak self] response in
                self?.isLoading = false
                
                switch response.result {
                case .success(let user):
                    // Extract token from headers
                    if let token = response.response?.allHeaderFields["Authorization"] as? String {
                        let tokenWithoutBearer = token.replacingOccurrences(of: "Bearer ", with: "")
                        UserDefaults.standard.set(tokenWithoutBearer, forKey: "userToken")
                    }
                    
                    if user.id != 0 {
                        self?.user = user
                    } else {
                        self?.errorMessage = "Error occurred"
                    }
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
    }


}
