//
//  NetworkError.swift
//  study
//
//  Created by Park Kwonyong on 6/15/26.
//

import Foundation

public enum NetworkError: Error {
  case urlError
  case requestFailed(String)
  case dataNil
  case invalidResponse
  case failToDecode(String)
  case clientError(Int)
  case serverError(Int)
  case unknownStatus(Int)
  
  public var description: String {
    switch self {
    case .urlError:
      "URL이 올바르지 않습니다."
    case .requestFailed(let message):
      "서버 요청 실패: \(message)"
    case .dataNil:
      "데이터가 없습니다."
    case .invalidResponse:
      "응답값이 유효하지 않습니다."
    case .failToDecode(let description):
      "디코딩 에러: \(description)"
    case .clientError(let statusCode):
      "클라이언트 에러: \(statusCode)"
    case .serverError(let statusCode):
      "서버 에러: \(statusCode)"
    case .unknownStatus(let statusCode):
      "그 외의 상태코드: \(statusCode)"
    }
  }
}
