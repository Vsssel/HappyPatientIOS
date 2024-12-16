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
    private let baseURL = "http://64.225.71.203:2222"

    private init() {}

    func request<T: Decodable>(_ endpoint: String,
                               method: HTTPMethod,
                               parameters: [String: Any]? = nil,
                               queryItems: [URLQueryItem]? = nil,
                               auth: Bool = false,
                               responseType: T.Type) -> AnyPublisher<T, Error> {
        
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)")
        if let queryItems = queryItems {
            urlComponents?.queryItems = queryItems
        }
        
        guard let url = urlComponents?.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var headers: HTTPHeaders = []
        if auth, let token = AuthenticationManager.shared.getToken() {
            headers.add(name: "Auth", value: "Bearer \(token)")
        }
        
        return Future { promise in
            let encoding: ParameterEncoding = (method == .get || method == .delete) ? URLEncoding.default : JSONEncoding.default
            
            AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
                .validate()
                .responseDecodable(of: T.self) { response in
                    debugPrint(response)
                    
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
