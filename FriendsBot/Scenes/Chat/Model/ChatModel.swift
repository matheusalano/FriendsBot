//
//  ChatModel.swift
//  FriendsBot
//
//  Created by Matheus Alano on 19/10/19.
//  Copyright © 2019 Matheus Alano. All rights reserved.
//

import Foundation

struct ChatNewMessage: Decodable {
    
    let message: String
    let messageDate: Date
    let response: String
    let responseDate: Date
}
