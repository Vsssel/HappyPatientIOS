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

    private var token: String? {
        return UserDefaults.standard.string(forKey: "userToken")
    }

    func request<T: Decodable>(_ endpoint: String,
                               method: HTTPMethod,
                               parameters: [String: Any]? = nil,
                               auth: Bool = false,
                               responseType: T.Type) -> AnyPublisher<T, Error> {
        let url = "\(baseURL)\(endpoint)"
        
        var headers: HTTPHeaders = []
        if auth, let token = token {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }

        return Future { promise in
            AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseDecodable(of: T.self) { response in
                    debugPrint(response)
                    if let authorizationHeader = response.response?.allHeaderFields["Authorization"] as? String {
                        let token = authorizationHeader.replacingOccurrences(of: "Bearer ", with: "")
                        self.saveToken(token)
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

    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "userToken")
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: "userToken")
    }
}
