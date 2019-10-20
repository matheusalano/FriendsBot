//
//  ChatViewModel.swift
//  FriendsBot
//
//  Created by Matheus Alano on 18/10/19.
//  Copyright © 2019 Matheus Alano. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import CoreData

enum ChatMessageError: Error {
    case coreDataLoad
    case coreDataSave
}

final class ChatViewModel {
    
    //MARK: - Inputs
    let sendMessage: AnyObserver<String>
    let loadMessages: AnyObserver<Void>
    
    //MARK: - Outputs
    let messages: Observable<[SectionModel<Date, ChatMessage>]>
    let errorPublisher: Observable<Error>
    let isLoading: Observable<Bool>
    
    init(service: ChatServiceProtocol = ChatService()) {
        
        let _sendMessage = PublishSubject<String>()
        sendMessage = _sendMessage.asObserver()
        
        let _loadMessages = PublishSubject<Void>()
        loadMessages = _loadMessages.asObserver()
        
        let _error = PublishSubject<Error>()
        errorPublisher = _error.asObservable()
        
        let isLoadingRequest = ActivityIndicator()
        isLoading = isLoadingRequest.asObservable()
        
        let newMessage = _sendMessage
            .flatMap { message in
                service.sendMessage(message)
                    .asObservable()
                    .observeOn(MainScheduler.instance)
                    .trackActivity(isLoadingRequest)
                    .catchError { error in
                        _error.onNext(error)
                        return Observable.empty()
                    }
            }
            .do(onNext: { newMessage in
                guard
                    let managedContext = ChatViewModel.managedContext,
                    let entity = NSEntityDescription.entity(forEntityName: "ChatMessage", in: managedContext) else { return }

                let message = ChatMessage(entity: entity, insertInto: managedContext)
                message.identity = UUID()
                message.text = newMessage.message
                message.date = newMessage.messageDate
                message.fromUser = true
                
                let response = ChatMessage(entity: entity, insertInto: managedContext)
                response.identity = UUID()
                response.text = newMessage.response
                response.date = newMessage.responseDate
                response.fromUser = false

                do {
                  try managedContext.save()
                } catch {
                    _error.onNext(ChatMessageError.coreDataSave)
                }
            })
            .map({ _ in () })
        
        messages = Observable.merge(_loadMessages.asObservable(), newMessage)
            .flatMap({ _ -> Observable<[SectionModel<Date, ChatMessage>]> in
                guard let managedContext = ChatViewModel.managedContext else { return Observable.empty() }
                
                do {
                    let messages: [ChatMessage] = try managedContext.fetch(ChatMessage.fetchRequest())
                
                    let calendar = Calendar.current
                
                    let groupedMessages = Dictionary(grouping: messages) { message in
                        return calendar.startOfDay(for: message.date)
                    }.sorted(by: { ($0.0) < ($1.0) })
                    
                    let sectionedMessages: [SectionModel<Date, ChatMessage>] = groupedMessages.map { group in
                        let sortedMsgs = group.value.sorted(by: { $0.date < $1.date })
                        return SectionModel(model: group.key, items: sortedMsgs)
                    }
                
                    return Observable.just(sectionedMessages)
                } catch {
                    _error.onNext(ChatMessageError.coreDataLoad)
                    return Observable.empty()
                }
            })
    }
}

//MARK: - CoreData
extension ChatViewModel {
    
    class var managedContext: NSManagedObjectContext? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }
}
