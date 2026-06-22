//
//  RepositoryProtocol.swift
//  study
//
//  Created by Park Kwonyong on 6/15/26.
//

import Foundation

public protocol UserRepositoryProtocol {
  func fetchUser(query: String, page: Int) async -> Result<UserListResult, NetworkError>
  func getFavoriteUsers() -> Result<[UserListItem], CoreDataError>
  func saveFavorite(user: UserListItem) -> Result<Bool, CoreDataError>
  func deleteFavoriteUser(userId: Int) -> Result<Bool, CoreDataError>
}
