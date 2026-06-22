//
//  MockUserRepository.swift
//  studyTests
//
//  Created by Park Kwonyong on 6/17/26.
//

import Foundation
@testable import study

public struct MockUserRepository: UserRepositoryProtocol {
  public func fetchUser(query: String, page: Int) async -> Result<study.UserListResult, study.NetworkError> {
    .failure(.dataNil)
  }
  
  public func getFavoriteUsers() -> Result<[study.UserListItem], study.CoreDataError> {
    .failure(.entityNotFound(""))
  }
  
  public func saveFavorite(user: study.UserListItem) -> Result<Bool, study.CoreDataError> {
    .failure(.entityNotFound(""))
  }
  
  public func deleteFavoriteUser(userId: Int) -> Result<Bool, study.CoreDataError> {
    .failure(.entityNotFound(""))
  }
  
  
}
