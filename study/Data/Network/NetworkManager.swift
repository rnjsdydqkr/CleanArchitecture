//
//  NetworkManager.swift
//  study
//
//  Created by Park Kwonyong on 6/16/26.
//

import Foundation
import Alamofire

/***
 NetworkManager(session: UserSession()) // 구현단
 NetworkManager(session: MockSession()) // 테스트단
 ***/

public class NetworkManager {
  private let session: SessionProtocol
  init(session: SessionProtocol) {
    self.session = session
  }
  
  private let tokenHeader: HTTPHeaders = {
    let tokenHeader = HTTPHeader(name: "Authorization", value: "Bearer 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")
    return HTTPHeaders(arrayLiteral: tokenHeader)
  }()
  
  func fetchData<T: Decodable>(url: String, method: HTTPMethod, parameter: Parameters?, encoding: ParameterEncoding) async -> Result<T, NetworkError> {
    guard let url = URL(string: url) else {
      return .failure(.urlError)
    }
    let result = await session.request(url, method: method, parameters: parameter, encoding: encoding, headers: tokenHeader).serializingData().response
    if let error = result.error { return .failure(.requestFailed(error.localizedDescription)) }
    guard let data = result.data else { return .failure(.dataNil) }
    guard let response = result.response else { return .failure(.invalidResponse) }
    if 200..<300 ~= response.statusCode {
      do {
        let data = try JSONDecoder().decode(T.self, from: data)
        return .success(data)
      } catch {
        return .failure(.failToDecode(error.localizedDescription))
      }
    } else if 300..<400 ~= response.statusCode {
      return .failure(.invalidResponse)
    } else if 400..<500 ~= response.statusCode {
      return .failure(.clientError(response.statusCode))
    } else if 500..<600 ~= response.statusCode {
      return .failure(.serverError(response.statusCode))
    } else {
      return .failure(.unknownStatus(response.statusCode))
    }
    
  }
  
}
