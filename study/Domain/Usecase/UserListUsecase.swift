//
//  UserListUsecase.swift
//  study
//
//  Created by Park Kwonyong on 6/15/26.
//

import Foundation

public protocol UserListUsecaseProtocol {
  func fetchUser(query: String, page: Int) async -> Result<UserListResult, NetworkError> // 유저 리스트 불러오기 (원격)
  func getFavoriteUsers() -> Result<[UserListItem], CoreDataError> // 전체 즐겨찾기 리스트 불러오기
  func saveFavorite(user: UserListItem) -> Result<Bool, CoreDataError>
  func deleteFavoriteUser(userId: Int) -> Result<Bool, CoreDataError>
  // 유저리스트 - 즐겨찾기 포함된 유저인지 체크
  func checkFavoriteState(fetchUsers: [UserListItem], favoriteUsers: [UserListItem]) -> [(user: UserListItem, isFavorite: Bool)]
  // 배열 -> Dictionary [초성: [유저리스트]]
  func convertListToDictionary(favoriteUsers: [UserListItem]) -> [String: [UserListItem]]
}

public struct UserListUsecase: UserListUsecaseProtocol {
  private var repository: UserRepositoryProtocol
  init (repository: UserRepositoryProtocol) {
    self.repository = repository
  }
  
  public func fetchUser(query: String, page: Int) async -> Result<UserListResult, NetworkError> {
    await repository.fetchUser(query: query, page: page)
  }
  
  public func getFavoriteUsers() -> Result<[UserListItem], CoreDataError> {
    repository.getFavoriteUsers()
  }
  
  public func saveFavorite(user: UserListItem) -> Result<Bool, CoreDataError> {
    repository.saveFavorite(user: user)
  }
  
  public func deleteFavoriteUser(userId: Int) -> Result<Bool, CoreDataError> {
    repository.deleteFavoriteUser(userId: userId)
  }
  
  public func checkFavoriteState(fetchUsers: [UserListItem], favoriteUsers: [UserListItem]) -> [(user: UserListItem, isFavorite: Bool)] {
    let favoriteSet = Set(favoriteUsers)
    return fetchUsers.map { user in
      if favoriteSet.contains(user) {
        return (user: user, isFavorite: true)
      } else {
        return (user: user, isFavorite: false)
      }
    }
  }
  
  public func convertListToDictionary(favoriteUsers: [UserListItem]) -> [String : [UserListItem]] {
    favoriteUsers.reduce(into: [String : [UserListItem]]()) { dict, user in
      if let firstString = user.login.first {
        let key = String(firstString).uppercased()
        dict[key, default: []].append(user)
      }
    }
  }
  
}
