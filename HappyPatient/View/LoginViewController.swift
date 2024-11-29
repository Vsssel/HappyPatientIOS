//
//  LoginViewConytoller.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 29.11.2024.
//

import UIKit
import SnapKit
import Combine

class LoginViewController: UIViewController {
    private let viewModel = LoginViewModel()
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - UI Components
    private lazy var usernameLabel: UILabel = createLabel(text: "Login", font: .systemFont(ofSize: 16))
    private lazy var passwordLabel: UILabel = createLabel(text: "Password", font: .systemFont(ofSize: 16))
    private lazy var titleLabel: UILabel = createLabel(text: "Login", font: .systemFont(ofSize: 25, weight: .medium), alignment: .center)
    private lazy var usernameAsteriskIcon: UIImageView = createAsteriskIcon()
    private lazy var passwordAsteriskIcon: UIImageView = createAsteriskIcon()
    private lazy var usernameTextField: UITextField = createTextField(placeholder: "Enter your IIN or Email")
    private lazy var passwordTextField: UITextField = {
        let textField = createTextField(placeholder: "Enter Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    private lazy var loginButton: UIButton = createButton(title: "Log In", backgroundColor: .systemBlue, action: #selector(didTapLogin))
    private lazy var signupButton: UIButton = createButton(title: "Register", textColor: .systemBlue, action: #selector(didTapSignup))
    private lazy var signupContainer: UIStackView = createSignupContainer()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        bindViewModel()
    }

    // MARK: - Setup Views
    private func setupViews() {
        let usernameLabelContainer = createHorizontalStack(views: [usernameLabel, usernameAsteriskIcon])
        let passwordLabelContainer = createHorizontalStack(views: [passwordLabel, passwordAsteriskIcon])
        let usernameViewStack = createVerticalStack(views: [usernameLabelContainer, usernameTextField])
        let passwordViewStack = createVerticalStack(views: [passwordLabelContainer, passwordTextField])
        let mainStack = createVerticalStack(views: [titleLabel, usernameViewStack, passwordViewStack, loginButton, signupContainer], spacing: 20)

        let containerView = createContainerView()
        view.addSubview(containerView)
        containerView.addSubview(mainStack)

        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    // MARK: - Bind ViewModel
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loginButton.isEnabled = !isLoading
                self?.loginButton.backgroundColor = isLoading ? .gray : .systemBlue
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let errorMessage = errorMessage, !errorMessage.isEmpty else { return }
                self?.showAlert(title: "Error", message: errorMessage)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions
    @objc private func didTapLogin() {
        guard let username = usernameTextField.text, let password = passwordTextField.text, !username.isEmpty, !password.isEmpty else {
            showAlert(title: "Error", message: "Login and password should not be empty")
            return
        }
        viewModel.login(username: username, password: password)
    }

    @objc private func didTapSignup() {
        let signupVC = SignUpViewController()
        signupVC.modalPresentationStyle = .fullScreen
        present(signupVC, animated: true)
    }

    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func createLabel(text: String, font: UIFont, alignment: NSTextAlignment = .natural) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textAlignment = alignment
        return label
    }

    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        return textField
    }

    private func createButton(title: String, backgroundColor: UIColor = .clear, textColor: UIColor = .white, action: Selector? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: .normal)
        button.layer.cornerRadius = 8
        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        return button
    }

    private func createAsteriskIcon() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "asterisk")
        imageView.tintColor = .red
        return imageView
    }

    private func createContainerView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        return view
    }

    private func createHorizontalStack(views: [UIView], spacing: CGFloat = 4) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.spacing = spacing
        stack.alignment = .lastBaseline
        stack.distribution = .equalSpacing
        return stack
    }

    private func createVerticalStack(views: [UIView], spacing: CGFloat = 8) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }

    private func createSignupContainer() -> UIStackView {
        let label = createLabel(text: "Don't have an account?", font: .systemFont(ofSize: 16))
        let stack = createHorizontalStack(views: [label, signupButton])
        stack.alignment = .center
        return stack
    }
}

