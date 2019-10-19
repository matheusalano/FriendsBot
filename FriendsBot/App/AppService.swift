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
        let stringURL = baseUrl + "\(path.rawValue)"
        
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
        
        print("\n###### 🛫🛫🛫 REQUEST: \(stringURL) ######\n")
        print("###### METHOD: \(method.rawValue) ######")
        print("###### HEADERS ######\n")
        print("\(urlRequest.allHTTPHeaderFields ?? [:])\n")
        if method == .POST {
            
            if  let data = urlRequest.httpBody,
                let body = String(data: data, encoding: String.Encoding.utf8) {
                print("###### BODY ######\n")
                print(body)
            }
        }
        
        return session.rx
            .json(request: urlRequest)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap({ json throws -> Observable<T> in
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let jsonData = try decoder.decode(T.self, from: JSONSerialization.data(withJSONObject: json, options: .prettyPrinted))
                    
                    print(" ### 🛬🛬🛬 FINISHING \(method.rawValue) REQUEST ###")
                    print("###### BODY ######")
                    print(json)
                    
                    return Observable.just(jsonData)
                } catch let error {
                    print(" ### 🛬💥💥 ERROR ON \(method.rawValue) REQUEST ###")
                    print(error.localizedDescription)
                    print("###### BODY ######")
                    print(json)
                    return Observable.error(ServiceError.cannotParse)
                }
            })
    }
}
