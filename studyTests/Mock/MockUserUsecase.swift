//
//  MockUserUsecase.swift
//  studyTests
//
//  Created by Park Kwonyong on 6/23/26.
//

import Foundation
@testable import study

public class MockUserUsecase: UserListUsecaseProtocol {
  // MARK: - Stub: 테스트가 지정한 값을 그대로 돌려준다
  public var fetchUserResult: Result<UserListResult, NetworkError>?
  public var favoriteUserResult: Result<[UserListItem], CoreDataError>?

  // MARK: - Spy: "어떤 인자로 불렸는지"를 기록한다
  public private(set) var receivedQueries: [String] = []
  public private(set) var receivedPages: [Int] = []
  /// fetchUser 는 Task 안에서 비동기로 불리므로, 테스트가 호출 시점을 붙잡을 수 있도록 훅을 둔다
  public var onFetchUser: ((String, Int) -> Void)?

  public func fetchUser(query: String, page: Int) async -> Result<study.UserListResult, study.NetworkError> {
    receivedQueries.append(query)
    receivedPages.append(page)
    onFetchUser?(query, page)
    return fetchUserResult ?? .failure(.dataNil)
  }
  
  public func getFavoriteUsers() -> Result<[study.UserListItem], study.CoreDataError> {
    favoriteUserResult ?? .failure(.entityNotFound(""))
  }
  
  public func saveFavorite(user: study.UserListItem) -> Result<Bool, study.CoreDataError> {
    .success(true)
  }
  
  public func deleteFavoriteUser(userId: Int) -> Result<Bool, study.CoreDataError> {
    .success(true)
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
