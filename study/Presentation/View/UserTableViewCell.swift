//
//  UserTableViewCell.swift
//  study
//
//  Created by Park Kwonyong on 6/22/26.
//

import UIKit
import SnapKit
import Kingfisher

final class UserTableViewCell: UITableViewCell {
  static let id = "UserTableViewCell"
  
  private let userImageView = {
    let imageView = UIImageView()
    imageView.layer.borderColor = UIColor.gray.cgColor
    imageView.layer.borderWidth = 0.5
    imageView.layer.cornerRadius = 6
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private let nameLable = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16, weight: .semibold)
    label.numberOfLines = 2
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubview(userImageView)
    addSubview(nameLable)
    userImageView.snp.makeConstraints { make in
      make.leading.top.bottom.equalToSuperview().inset(20)
      make.width.height.equalTo(80)
    }
    nameLable.snp.makeConstraints { make in
      make.top.equalTo(userImageView)
      make.leading.equalTo(userImageView.snp.trailing).offset(8)
      make.trailing.equalToSuperview().inset(20)
    }
  }
  
  func apply(cellData: UserListCellData) {
    guard case let .user(user,isFavorite) = cellData else { return }
    userImageView.kf.setImage(with: URL(string: user.imageURL))
    nameLable.text = user.login
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
