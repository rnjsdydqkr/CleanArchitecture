//
//  SignUpViewModel.swift
//  study
//
//  Created by Park Kwonyong on 7/1/26.
//

import Foundation
import Combine

protocol SignUpViewModelProtocol {
  func transform(input: SignUpViewModel.Input) -> SignUpViewModel.Output
}

/***
 Combine 학습용 ViewModel (Input/Output 변환 방식)

 PassthroughSubject  ~ PublishSubject      : 현재값 없는 이벤트
 CurrentValueSubject ~ BehaviorSubject     : 현재값을 가진 상태
 removeDuplicates    ~ distinctUntilChanged
 share()             ~ share()             : Combine Publisher 는 기본이 cold
 flatMap + first()   ~ withLatestFrom      : Combine 엔 withLatestFrom 이 없다
*/

public final class SignUpViewModel: SignUpViewModelProtocol {
  private let usecase: SignUpUsecaseProtocol

  // submit 시점의 최신값을 읽기 위한 보관용 (withLatestFrom 대용)
  @Published private var email: String = ""
  @Published private var password: String = ""

  public init(usecase: SignUpUsecaseProtocol) {
    self.usecase = usecase
  }

  public struct Input { // VM 에게 전달되어야 할 이벤트
    let email: AnyPublisher<String, Never>
    let password: AnyPublisher<String, Never>
    let submit: AnyPublisher<Void, Never>
  }

  public struct Output { // VC 에게 전달될 뷰 데이터
    let emailValidation: AnyPublisher<ValidationState, Never>
    let passwordValidation: AnyPublisher<ValidationState, Never>
    let isSubmitEnabled: AnyPublisher<Bool, Never>
    let submitResult: AnyPublisher<String, Never>
  }

  public func transform(input: Input) -> Output {
    // assign(to:&$) 는 AnyCancellable 을 만들지 않고 VM 수명에 묶인다
    input.email.assign(to: &$email)
    input.password.assign(to: &$password)

    // share() 없으면 라벨 구독 / isSubmitEnabled 구독이 각각 debounce + 검증을 돌린다
    let emailValidation = input.email
      .removeDuplicates()
      .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
      .map { [usecase] email in usecase.validateEmail(email) }
      .share()

    let passwordValidation = input.password
      .removeDuplicates()
      .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
      .map { [usecase] password in usecase.validatePassword(password) }
      .share()

    let isSubmitEnabled = Publishers.CombineLatest(emailValidation, passwordValidation)
      .map { $0.isValid && $1.isValid }

    let form = Publishers.CombineLatest($email, $password)
      .map { SignUpForm(email: $0, password: $1) }

    let submitResult = input.submit
      .flatMap { _ in form.first() } // 최신값 1개만 뽑아 쓴다
      .filter { [usecase] form in
        // 버튼 비활성화가 1차 방어, debounce 대기 중 눌린 탭은 여기서 막는다
        usecase.validateEmail(form.email).isValid && usecase.validatePassword(form.password).isValid
      }
      .map { form in "회원가입 요청 전송\n이메일: \(form.email)" }

    return Output(
      emailValidation: emailValidation.eraseToAnyPublisher(),
      passwordValidation: passwordValidation.eraseToAnyPublisher(),
      isSubmitEnabled: isSubmitEnabled.eraseToAnyPublisher(),
      submitResult: submitResult.eraseToAnyPublisher()
    )
  }
}
