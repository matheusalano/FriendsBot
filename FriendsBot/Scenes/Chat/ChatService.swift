//
//  ChatService.swift
//  FriendsBot
//
//  Created by Matheus Alano on 18/10/19.
//  Copyright © 2019 Matheus Alano. All rights reserved.
//

import Foundation
import RxSwift

protocol ChatServiceProtocol {
    func sendMessage(_ message: String) -> Single<ChatNewMessage>
}

final class ChatService: ChatServiceProtocol {
    
    private let appService = AppService()
    
    func sendMessage(_ message: String) -> Single<ChatNewMessage> {
        let parameters: [String: Any] = ["message": message]
        
        return appService.request(path: .chat, method: .POST, parameters: parameters).asSingle()
    }
}
