//
//  Repository.swift
//  study
//
//  Created by Park Kwonyong on 6/16/26.
//

import Foundation

public struct UserRepository: UserRepositoryProtocol {
  private let coreData: UserCoreDataProtocol, network: UserNetworkProtocol
  init(coreData: UserCoreDataProtocol, network: UserNetworkProtocol) {
    self.coreData = coreData
    self.network = network
  }
  public func fetchUser(query: String, page: Int) async -> Result<UserListResult, NetworkError> {
    await network.fetchUser(query: query, page: page)
  }
  
  public func getFavoriteUsers() -> Result<[UserListItem], CoreDataError> {
    coreData.getFavoriteUsers()
  }
  
  public func saveFavorite(user: UserListItem) -> Result<Bool, CoreDataError> {
    coreData.saveFavorite(user: user)
  }
  
  public func deleteFavoriteUser(userId: Int) -> Result<Bool, CoreDataError> {
    coreData.deleteFavoriteUser(userId: userId)
  }
  
  
}
