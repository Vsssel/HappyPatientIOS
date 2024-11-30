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
                               parameters: [String: Any]?,
                               responseType: T.Type) -> AnyPublisher<T, Error> {
        let url = "\(baseURL)\(endpoint)"
        
        return Future { promise in
            AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
                .validate()
                .responseDecodable(of: T.self) { response in
                    print(response)
                    switch response.result {
                    case .success(let result):
                        promise(.success(result))
                        print(result)
                    case .failure(let error):
                        print(error)
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
