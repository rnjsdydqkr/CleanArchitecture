//
//  SignUpViewModel.swift
//  study
//
//  Created by Park Kwonyong on 7/1/26.
//

import Foundation
import Combine

/***
 Combine 학습용 ViewModel

 @Published: RxSwift의 BehaviorRelay/BehaviorSubject 와 유사. 초기값을 가지고 있고,
             값 변경 시 자동으로 downstream에 전달. `$` prefix 로 Publisher 접근 가능.

 sink: RxSwift 의 subscribe(onNext:) 와 유사. 값을 받아 side-effect 실행.

 assign(to:on:): keyPath 를 통해 값을 프로퍼티에 자동 할당.
 assign(to: &$property): @Published 프로퍼티에 직접 파이프. AnyCancellable 저장 불필요.

 removeDuplicates: RxSwift 의 distinctUntilChanged 와 동일.

 CombineLatest: RxSwift 와 동일. 두 Publisher 의 최신값을 조합.
*/

public final class SignUpViewModel {
  private let usecase: SignUpUsecaseProtocol

  // MARK: - Input (VC 에서 값을 세팅)
  @Published var email: String = ""
  @Published var password: String = ""

  // MARK: - Output (VC 에서 구독)
  @Published private(set) var emailValidation: ValidationState = .empty
  @Published private(set) var passwordValidation: ValidationState = .empty
  @Published private(set) var isSubmitEnabled: Bool = false
  @Published private(set) var submitResult: String? = nil

  public init(usecase: SignUpUsecaseProtocol) {
    self.usecase = usecase
    bind()
  }

  private func bind() {
    // email 입력 -> debounce -> 유효성 상태
    $email
      .removeDuplicates()
      .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
      .map { [usecase] email in usecase.validateEmail(email) }
      .assign(to: &$emailValidation)

    // password 입력 -> debounce -> 유효성 상태
    $password
      .removeDuplicates()
      .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
      .map { [usecase] password in usecase.validatePassword(password) }
      .assign(to: &$passwordValidation)

    // 두 유효성이 모두 valid 일 때 버튼 활성화
    Publishers.CombineLatest($emailValidation, $passwordValidation)
      .map { $0.isValid && $1.isValid }
      .assign(to: &$isSubmitEnabled)
  }

  // MARK: - Action
  public func submit() {
    guard isSubmitEnabled else { return }
    let form = SignUpForm(email: email, password: password)
    submitResult = "회원가입 요청 전송\n이메일: \(form.email)"
  }
}
