//
//  ChatTextFieldView.swift
//  FriendsBot
//
//  Created by Matheus Alano on 20/10/19.
//  Copyright © 2019 Matheus Alano. All rights reserved.
//

import UIKit

class ChatTextFieldView: UIView {
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.tintColor = UIColor(named: "friends_purple")
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "send"), for: .normal)
        button.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.tintColor = UIColor(named: "friends_purple")
        return button
    }()
    
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .prominent)
        return UIVisualEffectView(effect: blur)
    }()

    init(placeholder: String) {
        super.init(frame: .zero)
        
        textField.placeholder = placeholder
        
        addSubviews()
        installConstraints()
    }
        
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(blurView)
        addSubview(textField)
        addSubview(sendButton)
        addSubview(activityIndicator)
    }
    
    private func installConstraints() {
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(44)
            $0.top.equalToSuperview()
            $0.leading.equalTo(safeAreaLayoutGuide.snp.leading).inset(24)
            $0.trailing.equalTo(sendButton.snp.leading).inset(-16)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        sendButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 44, height: 44))
            $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing).inset(24)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalTo(sendButton.snp.center)
        }
    }
}
