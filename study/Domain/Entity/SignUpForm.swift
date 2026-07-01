//
//  SignUpForm.swift
//  study
//
//  Created by Park Kwonyong on 7/1/26.
//

import Foundation

public struct SignUpForm: Equatable {
  let email: String
  let password: String

  init(email: String, password: String) {
    self.email = email
    self.password = password
  }
}

public enum ValidationState: Equatable {
  case empty
  case valid
  case invalid(reason: String)

  var message: String {
    switch self {
    case .empty: return ""
    case .valid: return "사용 가능"
    case .invalid(let reason): return reason
    }
  }

  var isValid: Bool {
    if case .valid = self { return true }
    return false
  }
}
