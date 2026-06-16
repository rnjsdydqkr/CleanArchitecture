//
//  Network.swift
//  study
//
//  Created by Park Kwonyong on 6/16/26.
//

import Foundation
import Alamofire

public protocol SessionProtocol {
  func request(_ convertible: any URLConvertible,
               method: HTTPMethod,
               parameters: Parameters?,
               encoding: any ParameterEncoding,
               headers: HTTPHeaders?) -> DataRequest
}

class UserSession: SessionProtocol {
  private var session: Session
  init() {
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .returnCacheDataElseLoad
    self.session = Session(configuration: config)
  }
  
  func request(_ convertible: any URLConvertible,
               method: HTTPMethod = .get,
               parameters: Parameters? = nil,
               encoding: any ParameterEncoding = URLEncoding.default,
               headers: HTTPHeaders? = nil) -> DataRequest {
    session.request(convertible, method: method, parameters: parameters, encoding: encoding, headers: headers)
  }
  
}
