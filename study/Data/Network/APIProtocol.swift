//
//  APIProtocol.swift
//  study
//
//  Created by Park Kwonyong on 6/22/26.
//

import Foundation
import Alamofire

let testTargets = ["dev", "smpl", "tool"]
let currentTarget = Bundle.main.bundleIdentifier?.components(separatedBy: ".").last ?? ""
let isDevMode = testTargets.contains(currentTarget)

let productionBaseURL: String = "https://api.github.com"
let developmentBaseURL: String = "http://localhost:3000"

protocol APIProtocol {
  var baseURL: String { get }
  var url: String { get }
  var header: HTTPHeaders { get }
  var parameter: Encodable? { get }
  var method: HTTPMethod { get }
  var urlEncoding: URLEncoding { get }
}

extension APIProtocol {
  var baseURL: String {
    return isDevMode ? developmentBaseURL : productionBaseURL
  }
  
  var header: HTTPHeaders {
    var headers = HTTPHeaders()
    headers.add(.contentType("application/json"))
    return headers
  }
  
  var method: HTTPMethod {
    return .post
  }
  
  var urlEncoding: URLEncoding {
    return .httpBody
  }
  
}

extension Encodable {
  subscript(key: String) -> Any? {
    return dictionary[key]
  }
  var dictionary: [String: Any] {
    return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
  }
}
