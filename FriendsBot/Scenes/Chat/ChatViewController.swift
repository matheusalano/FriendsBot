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
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.description())
        return tableView
    }()
    
    init(viewModel: ChatViewModel) {
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadMessages.onNext(())
    }
    
    private func addSubviews() {
        
        view.addSubview(tableView)
    }
        
    private func installConstraints() {
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
            
    private func setupBindings() {
        
        viewModel.messages
            .bind(to: tableView.rx.items(dataSource: getTableDataSource()))
            .disposed(by: disposeBag)
    }
    
    private func getTableDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<Date, ChatMessage>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<Date, ChatMessage>>(
            configureCell: { (_, tableView, indexPath, element) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.description(), for: indexPath) as? ChatTableViewCell else {
                    return UITableViewCell()
                }
                
                cell.configure(message: element)
                return cell
            }
        )
    }
}
