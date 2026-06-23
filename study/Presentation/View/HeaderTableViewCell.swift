//
//  HeaderTableViewCell.swift
//  study
//
//  Created by Park Kwonyong on 6/23/26.
//

import UIKit
import SnapKit

final class HeaderTableViewCell: UITableViewCell, UserListCellProtocol {
  static let id = "HeaderTableViewCell"
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 20, weight: .bold)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.leading.bottom.equalToSuperview().inset(20)
    }
  }
  
  func apply(cellData: UserListCellData) {
    guard case let .header(title) = cellData else { return }
    titleLabel.text = title
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
