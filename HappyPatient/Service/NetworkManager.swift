//
//  NetworkManager.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 29.11.2024.
//

import Foundation
import Alamofire
import Combine

class NetworkManager {
    
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:2222"

    private init() {}

    func request<T: Decodable>(_ endpoint: String,
                               method: HTTPMethod,
                               parameters: [String: Any]? = nil,
                               auth: Bool = false,
                               responseType: T.Type) -> AnyPublisher<T, Error> {
        
        let url = "\(baseURL)\(endpoint)"
        
        // Use the AuthenticationManager for token management
        var headers: HTTPHeaders = []
        if auth, let token = AuthenticationManager.shared.getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        return Future { promise in
            AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseDecodable(of: T.self) { response in
                    debugPrint(response)
                    
                    // Check for a new token in response header and update it
                    if let authorizationHeader = response.response?.allHeaderFields["auth"] as? String {
                        let token = authorizationHeader.replacingOccurrences(of: "Bearer ", with: "")
                        print("NM Token: \(token)")
                        AuthenticationManager.shared.saveToken(token)
                    }
                    
                    switch response.result {
                    case .success(let result):
                        promise(.success(result))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func clearToken() {
        AuthenticationManager.shared.clearToken()
    }
}
