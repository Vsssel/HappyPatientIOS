import UIKit
import SnapKit

class SignUpViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let nameTextField = UITextField()
    private let surnameTextField = UITextField()
    private let emailTextField = UITextField()
    private let iinTextField = UITextField()
    private let nextButton = UIButton(type: .system)
    private let alreadyHaveAccountLabel = UILabel()
    private let loginButton = UIButton(type: .system)
    private let mainStack = UIStackView()
    
    private let viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        titleLabel.text = "Sign Up"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        
        [nameTextField, surnameTextField, emailTextField, iinTextField].forEach {
            $0.borderStyle = .roundedRect
            $0.font = UIFont.systemFont(ofSize: 16)
        }
        
        nameTextField.placeholder = "Name"
        surnameTextField.placeholder = "Surname"
        emailTextField.placeholder = "Email"
        iinTextField.placeholder = "IIN"
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        nextButton.backgroundColor = .systemBlue
        nextButton.tintColor = .white
        nextButton.layer.cornerRadius = 8
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        alreadyHaveAccountLabel.text = "Already have an account?"
        alreadyHaveAccountLabel.font = UIFont.systemFont(ofSize: 14)
        
        loginButton.setTitle("Log in", for: .normal)
        loginButton.setTitleColor(.systemBlue, for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        view.addSubview(mainStack)
        
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(nameTextField)
        mainStack.addArrangedSubview(surnameTextField)
        mainStack.addArrangedSubview(emailTextField)
        mainStack.addArrangedSubview(iinTextField)
        mainStack.addArrangedSubview(nextButton)
        
        let bottomStack = UIStackView(arrangedSubviews: [alreadyHaveAccountLabel, loginButton])
        bottomStack.spacing = 4
        bottomStack.alignment = .center
        mainStack.addArrangedSubview(bottomStack)
        
        mainStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.left.right.equalToSuperview().inset(16)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
    }
    
    private func setupBindings() {
        viewModel.$isLoading.sink { [weak self] isLoading in
            self?.nextButton.isEnabled = !isLoading
            self?.nextButton.alpha = isLoading ? 0.5 : 1.0
        }
        .store(in: &viewModel.cancellables)
        
        viewModel.$errorMessage.sink { [weak self] errorMessage in
            if let errorMessage = errorMessage {
                self?.showErrorAlert(message: errorMessage)
            }
        }
        .store(in: &viewModel.cancellables)
        
        viewModel.$emailSent
            .sink { [weak self] success in
                if success! {
                    let confirmationVC = EmailConfirmationViewController()
                    self?.navigationController?.pushViewController(confirmationVC, animated: true)
                }
            }
            .store(in: &viewModel.cancellables)
    }
    
    @objc private func nextButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let iin = iinTextField.text, !iin.isEmpty else {
            showErrorAlert(message: "Please fill in all fields.")
            return
        }
        
        viewModel.emailVerification(email: email, iin: iin)
    }
    
    @objc private func loginButtonTapped() {
        // Navigate to the Login ViewController
        dismiss(animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
