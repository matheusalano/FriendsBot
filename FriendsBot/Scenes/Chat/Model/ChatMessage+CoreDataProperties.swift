//
//  ChatMessage+CoreDataProperties.swift
//  FriendsBot
//
//  Created by Matheus Alano on 19/10/19.
//  Copyright © 2019 Matheus Alano. All rights reserved.
//
//

import Foundation
import CoreData


extension ChatMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatMessage> {
        return NSFetchRequest<ChatMessage>(entityName: "ChatMessage")
    }

    @NSManaged public var date: Date?
    @NSManaged public var fromUser: Bool
    @NSManaged public var text: String?

}
