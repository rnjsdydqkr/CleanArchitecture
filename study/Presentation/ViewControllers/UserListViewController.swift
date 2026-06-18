//
//  UserListViewController.swift
//  study
//
//  Created by Park Kwonyong on 6/18/26.
//

import UIKit

class UserListViewController: UIViewController {
  private let viewmodel: UserListViewModelProtocol
  init(viewModel: UserListViewModelProtocol) {
    self.viewmodel = viewModel
    super.init(nibName: nil, bundle: nil)
    
    view.backgroundColor = .systemGray
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
}
