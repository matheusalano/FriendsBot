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
    
    private let bubbleImageView = UIImageView()
    private let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
        messageLabel.adjustsFontForContentSizeCategory = true

        bubbleImageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        selectionStyle = .none
        
        addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func installConstraints(_ fromUser: Bool, isFirstCell: Bool, isLastCell: Bool) {
        bubbleImageView.snp.remakeConstraints {
            $0.width.greaterThanOrEqualTo(42)
            $0.top.equalToSuperview().inset(isFirstCell ? 16 : 4)
            $0.bottom.equalToSuperview().inset(isLastCell ? 16 : 4)
            
            if fromUser {
                $0.leading.greaterThanOrEqualToSuperview().inset(64)
                $0.trailing.equalToSuperview().inset(24)
            } else {
                $0.leading.equalToSuperview().inset(24)
                $0.trailing.lessThanOrEqualToSuperview().inset(64)
            }
        }
        
        messageLabel.snp.remakeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: fromUser ? 12 : 20, bottom: 8, right: fromUser ? 20 : 12))
        }
    }
    
    func configure(message: ChatMessage, isFirstCell: Bool, isLastCell: Bool) {
        installConstraints(message.fromUser, isFirstCell: isFirstCell, isLastCell: isLastCell)
        
        let image = UIImage(named: message.fromUser ? "chat_bubble_sent" : "chat_bubble_received")
        
        bubbleImageView.image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch)
        
        bubbleImageView.tintColor = UIColor(named: message.fromUser ? "bubble_sent" : "bubble_received")
        
        messageLabel.text = message.text
        messageLabel.textColor = UIColor(named: message.fromUser ? "text_sent" : "text_received")
    }
    
}
