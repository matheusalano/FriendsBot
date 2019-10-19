//
//  AppService.swift
//  FriendsBot
//
//  Created by Matheus Alano on 18/10/19.
//  Copyright © 2019 Matheus Alano. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum APIPaths: String {
    case chat = "chat/"
}

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

enum ServiceError: Error {
    case cannotParse
    case cannotParseParameters
    case invalidURL
}

class AppService {
    
    private let baseUrl = "http://35.199.66.84:5000/"
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func request<T: Decodable>(path: APIPaths, method: HTTPMethod, parameters: [String: Any]? = nil) -> Observable<T> {
        let stringURL = baseUrl + "/\(path.rawValue)"
        
        guard let url = URL(string: stringURL) else { return Observable.error(ServiceError.invalidURL) }
        var urlRequest = URLRequest(url: url)
        
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch _ {
                return Observable.error(ServiceError.cannotParseParameters)
            }
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest.httpMethod = method.rawValue
        
        return session.rx
            .json(request: urlRequest)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap({ json throws -> Observable<T> in
                do {
                    let jsonData = try JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: json, options: .prettyPrinted))
                    
                    return Observable.just(jsonData)
                } catch let error {
                    print(error.localizedDescription)
                    return Observable.error(ServiceError.cannotParse)
                }
            })
    }
}
