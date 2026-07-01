//
//  SignUpUsecase.swift
//  study
//
//  Created by Park Kwonyong on 7/1/26.
//

import Foundation

public protocol SignUpUsecaseProtocol {
  func validateEmail(_ email: String) -> ValidationState
  func validatePassword(_ password: String) -> ValidationState
}

public struct SignUpUsecase: SignUpUsecaseProtocol {
  private var repository: SignUpRepositoryProtocol
  init(repository: SignUpRepositoryProtocol) {
    self.repository = repository
  }

  public func validateEmail(_ email: String) -> ValidationState {
    if email.isEmpty { return .empty }
    let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    return predicate.evaluate(with: email)
    ? .valid
    : .invalid(reason: "올바른 이메일 형식이 아닙니다.")
  }

  public func validatePassword(_ password: String) -> ValidationState {
    if password.isEmpty { return .empty }
    if password.count < 8 {
      return .invalid(reason: "8자 이상 입력해 주세요.")
    }
    let hasLetter = password.contains { $0.isLetter }
    let hasDigit = password.contains { $0.isNumber }
    if !(hasLetter && hasDigit) {
      return .invalid(reason: "영문과 숫자를 함께 입력해 주세요.")
    }
    return .valid
  }
}
