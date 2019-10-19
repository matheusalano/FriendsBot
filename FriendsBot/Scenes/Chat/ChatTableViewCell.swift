//
//  ChatTableViewCell.swift
//  FriendsBot
//
//  Created by Matheus Alano on 19/10/19.
//  Copyright © 2019 Matheus Alano. All rights reserved.
//

import UIKit
import SnapKit

class ChatTableViewCell: UITableViewCell {
    
    private let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24))
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(message: ChatMessage) {
        
        messageLabel.text = message.text
        messageLabel.textAlignment = message.fromUser ? .right : .left
    }
}
