//
//  UserAPI.swift
//  study
//
//  Created by Park Kwonyong on 6/22/26.
//

import Alamofire

enum UserAPI: APIProtocol {
  case fetch(query: String, page: Int)
}
extension UserAPI {
  var url: String {
    switch self {
    case .fetch:
      return "/search/users"
    }
  }
  
  var header: HTTPHeaders {
    let headers = HTTPHeaders()
    return headers
  }
  
  var parameter: Encodable? {
    switch self {
    case .fetch(query: let query, page: let page):
      return UserListFetchParameter(q: query, page: page)
    }
  }
  
  var method: HTTPMethod {
    switch self {
    case .fetch:
      return .get
    }
  }
  
  var urlEncoding: URLEncoding {
    switch self {
    case .fetch:
      return .queryString
    }
  }
  
}

struct UserListFetchParameter: Encodable {
  let q: String
  let page: Int
}
