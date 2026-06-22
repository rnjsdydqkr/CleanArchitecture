//
//  UserNetwork.swift
//  study
//
//  Created by Park Kwonyong on 6/16/26.
//



import Foundation
import Alamofire

public protocol UserNetworkProtocol {
  func fetchUser(query: String, page: Int) async -> Result<UserListResult, NetworkError>
}

final public class UserNetwork: UserNetworkProtocol {
  private let manager: NetworkManagerProtocol
  init(manager: NetworkManagerProtocol) {
    self.manager = manager
  }
  
  public func fetchUser(query: String, page: Int) async -> Result<UserListResult, NetworkError> {
//    let url = "https://api.github.com/search/users?q=\(query)&page=\(page)"
//    return await manager.fetchData(url: url, method: .get, parameter: nil, encoding: URLEncoding.default)
    return await manager.fetchDataList(api: UserAPI.fetch(query: query, page: page))
  }
  
}
