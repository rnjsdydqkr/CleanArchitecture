//
//  SignUpViewController.swift
//  study
//
//  Created by Park Kwonyong on 7/1/26.
//

import UIKit
import SnapKit
import Combine

final class SignUpViewController: UIViewController {
  private let viewModel: SignUpViewModelProtocol
  private let emailInput = CurrentValueSubject<String, Never>("") // 텍스트필드는 항상 현재값을 가진다
  private let passwordInput = CurrentValueSubject<String, Never>("")
  private let submitTapped = PassthroughSubject<Void, Never>() // 탭은 현재값이 없는 순간 이벤트
  private var cancellables = Set<AnyCancellable>()

  private let emailTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "이메일"
    tf.borderStyle = .roundedRect
    tf.keyboardType = .emailAddress
    tf.autocapitalizationType = .none
    tf.autocorrectionType = .no
    return tf
  }()

  private let emailValidationLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 12)
    return label
  }()

  private let passwordTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "비밀번호 (영문 + 숫자, 8자 이상)"
    tf.borderStyle = .roundedRect
    tf.isSecureTextEntry = true
    return tf
  }()

  private let passwordValidationLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 12)
    return label
  }()

  private let submitButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("회원가입", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.setTitleColor(.lightGray, for: .disabled)
    button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    button.layer.cornerRadius = 8
    button.isEnabled = false
    button.backgroundColor = .systemGray4
    return button
  }()

  init(viewModel: SignUpViewModelProtocol) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    title = "회원가입"
    setUI()
    bindView()
    bindViewModel()
  }

  private func setUI() {
    view.addSubview(emailTextField)
    view.addSubview(emailValidationLabel)
    view.addSubview(passwordTextField)
    view.addSubview(passwordValidationLabel)
    view.addSubview(submitButton)

    emailTextField.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(44)
    }
    emailValidationLabel.snp.makeConstraints { make in
      make.top.equalTo(emailTextField.snp.bottom).offset(4)
      make.leading.trailing.equalTo(emailTextField)
      make.height.equalTo(16)
    }
    passwordTextField.snp.makeConstraints { make in
      make.top.equalTo(emailValidationLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(44)
    }
    passwordValidationLabel.snp.makeConstraints { make in
      make.top.equalTo(passwordTextField.snp.bottom).offset(4)
      make.leading.trailing.equalTo(passwordTextField)
      make.height.equalTo(16)
    }
    submitButton.snp.makeConstraints { make in
      make.top.equalTo(passwordValidationLabel.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(50)
    }
  }

  private func bindView() {
    // UITextField 는 기본 Combine publisher 가 없어 NotificationCenter 로 텍스트 변화를 구독
    NotificationCenter.default
      .publisher(for: UITextField.textDidChangeNotification, object: emailTextField)
      .compactMap { ($0.object as? UITextField)?.text }
      .sink { [weak self] text in self?.emailInput.send(text) }
      .store(in: &cancellables)

    NotificationCenter.default
      .publisher(for: UITextField.textDidChangeNotification, object: passwordTextField)
      .compactMap { ($0.object as? UITextField)?.text }
      .sink { [weak self] text in self?.passwordInput.send(text) }
      .store(in: &cancellables)

    submitButton.addAction(UIAction { [weak self] _ in
      self?.submitTapped.send(())
    }, for: .touchUpInside)
  }

  private func bindViewModel() {
    let output = viewModel.transform(input: SignUpViewModel.Input(
      email: emailInput.eraseToAnyPublisher(),
      password: passwordInput.eraseToAnyPublisher(),
      submit: submitTapped.eraseToAnyPublisher()
    ))

    output.emailValidation
      .sink { [weak self] state in
        self?.apply(state: state, to: self?.emailValidationLabel)
      }
      .store(in: &cancellables)

    output.passwordValidation
      .sink { [weak self] state in
        self?.apply(state: state, to: self?.passwordValidationLabel)
      }
      .store(in: &cancellables)

    output.isSubmitEnabled
      .sink { [weak self] enabled in
        self?.submitButton.isEnabled = enabled
        self?.submitButton.backgroundColor = enabled ? .systemBlue : .systemGray4
      }
      .store(in: &cancellables)

    output.submitResult
      .sink { [weak self] message in
        let alert = UIAlertController(title: "완료", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "확인", style: .default))
        self?.present(alert, animated: true)
      }
      .store(in: &cancellables)
  }

  private func apply(state: ValidationState, to label: UILabel?) {
    label?.text = state.message
    switch state {
    case .valid:
      label?.textColor = .systemGreen
    case .invalid:
      label?.textColor = .systemRed
    case .empty:
      label?.textColor = .clear
    }
  }
}
