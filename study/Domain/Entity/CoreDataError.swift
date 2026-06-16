//
//  CoreDataError.swift
//  study
//
//  Created by Park Kwonyong on 6/15/26.
//

import Foundation

public enum CoreDataError: Error {
  case entityNotFound(String)
  case saveError(String)
  case readError(String)
  case deleteError(String)
  
  public var description: String {
    switch self {
    case .entityNotFound(let objectName):
      "객체를 찾을 수 없습니다: \(objectName)"
    case .saveError(let message):
      "객체 저장 에러: \(message)"
    case .readError(let message):
      "객체 조회 에러: \(message)"
    case .deleteError(let message):
      "객체 삭제 에러: \(message)"
    }
  }
}
