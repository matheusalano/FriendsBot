//
//  ChatViewController.swift
//  FriendsBot
//
//  Created by Matheus Alano on 18/10/19.
//  Copyright © 2019 Matheus Alano. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class ChatViewController: UIViewController {

    private let viewModel: ChatViewModel
    private let disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 32
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.clipsToBounds = false
        tableView.tableFooterView = UIView(frame: .init(origin: .zero, size: .init(width: 0, height: 24)))
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.description())
        return tableView
    }()
    
    private let chatTextFieldView = ChatTextFieldView(placeholder: "Text Message")
    
    private var textField: UITextField {
        return chatTextFieldView.textField
    }
    
    init(viewModel: ChatViewModel) {
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        title = "F.r.i.e.n.d.s b.o.t"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor(named: "background")
        
        addSubviews()
        installConstraints()
        setupBindings()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadMessages.onNext(())
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.contentInsetAdjustmentBehavior = .always
        let tableInsets = UIEdgeInsets(top: 0, left: 0, bottom: textField.bounds.height, right: 0)
        tableView.contentInset = tableInsets
        tableView.scrollIndicatorInsets = tableInsets
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.scrollTableViewToBottom()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addSubviews() {
        
        view.addSubview(tableView)
        view.addSubview(chatTextFieldView)
    }
        
    private func installConstraints() {
        
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalToSuperview()
        }
        
        chatTextFieldView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
            
    private func setupBindings() {
        
        viewModel.messages
            .do(onNext: { [weak self] _ in self?.textField.text = "" }, afterNext: { [weak self] _ in self?.scrollTableViewToBottom() })
            .bind(to: tableView.rx.items(dataSource: getTableDataSource()))
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: chatTextFieldView.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: chatTextFieldView.sendButton.rx.isHidden)
        .disposed(by: disposeBag)
        
        viewModel.isLoading
            .map({ !$0 })
            .bind(to: textField.rx.isUserInteractionEnabled)
        .disposed(by: disposeBag)
        
        chatTextFieldView.sendButton.rx.tap
            .throttle(.milliseconds(5000), scheduler: MainScheduler.asyncInstance)
            .withLatestFrom(textField.rx.text.orEmpty)
            .bind(to: viewModel.sendMessage)
            .disposed(by: disposeBag)
        
        textField.rx.text
            .map({ $0?.isEmpty == false })
            .bind(to: chatTextFieldView.sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] _ in
                if self?.textField.isFirstResponder == true {
                    self?.textField.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteChatMessages))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.label
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.label,
         NSAttributedString.Key.font: UIFont(name: "GabrielWeissFriendsFont", size: UIFont.labelFontSize)!]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label,
        NSAttributedString.Key.font: UIFont(name: "GabrielWeissFriendsFont", size: 34)!]
    }
    
    private func getTableDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<Date, ChatMessage>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<Date, ChatMessage>>(
            configureCell: { (_, tableView, indexPath, element) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.description(), for: indexPath) as? ChatTableViewCell else {
                    return UITableViewCell()
                }
                
                let isFirst = indexPath.row == 0
                let isLast = (tableView.numberOfRows(inSection: indexPath.section) - 1) == indexPath.row
                cell.configure(message: element, isFirstCell: isFirst, isLastCell: isLast)
                return cell
            }, titleForHeaderInSection: { ds, index in
                let dtFormatter = DateFormatter()
                dtFormatter.dateStyle = .medium
                dtFormatter.locale = Locale.current
                return dtFormatter.string(from: ds.sectionModels[index].model)
            }
        )
    }
    
    private func scrollTableViewToBottom() {
        if tableView.contentSize.height > tableView.bounds.height {
            tableView.setContentOffset(.init(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: true)
            tableView.reloadData()
        }
    }
    
    @objc private func deleteChatMessages() {
        let alert = UIAlertController(title: "Clear messages", message: "Are you sure you want to delete all your messages?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.clearMessages.onNext(())
        }))
        
        present(alert, animated: true)
    }
    
    @objc private func keyboardDidShow(notification: Notification) {
        
        scrollTableViewToBottom()
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        chatTextFieldView.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(keyboardFrame.height)
        }
        
        tableView.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(keyboardFrame.height)
        }
        
        UIView.animate(withDuration: animationDuration) { self.view.layoutIfNeeded() }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        chatTextFieldView.snp.updateConstraints {
            $0.bottom.equalToSuperview()
        }
        
        tableView.snp.updateConstraints {
            $0.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: animationDuration) { self.view.layoutIfNeeded() }
    }
}
