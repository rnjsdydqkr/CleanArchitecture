//
//  UserTableViewCell.swift
//  study
//
//  Created by Park Kwonyong on 6/22/26.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift

final class UserTableViewCell: UITableViewCell {
  static let id = "UserTableViewCell"
  var disposeBag = DisposeBag()
  
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
  
  public let favoriteButton = {
    let button = UIButton()
    button.setImage(.init(systemName: "heart"), for: .normal)
    button.setImage(.init(systemName: "heart.fill"), for: .selected)
    button.tintColor = .systemRed
    return button
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(userImageView)
    contentView.addSubview(nameLable)
    contentView.addSubview(favoriteButton)
    userImageView.snp.makeConstraints { make in
      make.leading.top.bottom.equalToSuperview().inset(20)
      make.width.equalTo(80)
      make.height.equalTo(80).priority(.high)
    }
    nameLable.snp.makeConstraints { make in
      make.top.equalTo(userImageView)
      make.leading.equalTo(userImageView.snp.trailing).offset(8)
      make.trailing.equalToSuperview().inset(20)
    }
    favoriteButton.snp.makeConstraints { make in
      make.width.height.equalTo(40)
      make.centerY.equalToSuperview()
      make.trailing.equalTo(-20)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
  
  func apply(cellData: UserListCellData) {
    guard case let .user(user, isFavorite) = cellData else { return }
    userImageView.kf.setImage(with: URL(string: user.imageURL))
    nameLable.text = user.login
    favoriteButton.isSelected = isFavorite
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
