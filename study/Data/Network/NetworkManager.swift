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

protocol NetworkManagerProtocol {
  func fetchData<T: Decodable>(url: String, method: HTTPMethod, parameter: Parameters?, encoding: ParameterEncoding) async -> Result<T, NetworkError>
  func fetchDataList<T: Decodable>(api: APIProtocol) async -> Result<T, NetworkError>
}

public class NetworkManager: NetworkManagerProtocol {
  private let session: SessionProtocol
  init(session: SessionProtocol) {
    self.session = session
  }
  
  private func makeURL(apiRouter: APIProtocol) -> (URL?, HTTPHeaders, Parameters?, HTTPMethod, URLEncoding) {
    return (URL(string: apiRouter.baseURL + apiRouter.url), apiRouter.header, apiRouter.parameter?.dictionary, apiRouter.method, apiRouter.urlEncoding)
  }
  
  func fetchData<T: Decodable>(url: String, method: HTTPMethod, parameter: Parameters?, encoding: ParameterEncoding) async -> Result<T, NetworkError> {
    guard let url = URL(string: url) else {
      return .failure(.urlError)
    }
    let result = await session.request(url, method: method, parameters: parameter, encoding: encoding, headers: HTTPHeaders()).serializingData().response
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
  
  func fetchDataList<T: Decodable>(api: APIProtocol) async -> Result<T, NetworkError> {
    
    let (fullURL, header, parameter, method, encoding) = makeURL(apiRouter: api)
    
    guard let fullURL else { return .failure(.urlError) }
    let result = await session.request(fullURL, method: method, parameters: parameter, encoding: encoding, headers: header).serializingData().response
    
    if let error = result.error { return .failure(.requestFailed(error.localizedDescription)) }
    guard let data = result.data else { return .failure(.dataNil) }
    if let jsonString = String(data: data, encoding: .utf8) { print(jsonString) }
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
