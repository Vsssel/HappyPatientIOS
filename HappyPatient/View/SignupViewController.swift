import UIKit
import SnapKit
import Combine

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
    private let contentView = UIView()
    
    private let viewModel = SignUpViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    public var user: TempUserInfo?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        titleLabel.text = "Sign Up"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        
        nameTextField.setupPlaceholder("Name")
        surnameTextField.setupPlaceholder("Surname")
        emailTextField.setupPlaceholder("Email", keyboardType: .emailAddress)
        iinTextField.setupPlaceholder("IIN", keyboardType: .numberPad)
        
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
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 6
        
        contentView.addSubview(mainStack)
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.nextButton.isEnabled = !isLoading
                self?.nextButton.alpha = isLoading ? 0.5 : 1.0
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showErrorAlert(message: errorMessage)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$emailSent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                guard success == true else { return }
                let confirmationVC = EmailConfirmationViewController()
                confirmationVC.user = self!.user
                confirmationVC.modalPresentationStyle = .fullScreen
                self?.present(confirmationVC, animated: true)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func nextButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let iin = iinTextField.text, !iin.isEmpty,
              let name = nameTextField.text, !name.isEmpty,
              let surname = surnameTextField.text, !surname.isEmpty else {
            showErrorAlert(message: "Please fill in all fields.")
            return
        }
        
        guard isValidEmail(email) else {
            showErrorAlert(message: "Invalid email address.")
            return
        }
        
        user = TempUserInfo(name: name, surname: surname, email: email, iin: iin)
        viewModel.emailVerification(email: email, iin: iin)
    }
    
    @objc private func loginButtonTapped() {
        dismiss(animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Extensions
private extension UITextField {
    func setupPlaceholder(_ placeholder: String, keyboardType: UIKeyboardType = .default) {
        self.placeholder = placeholder
        self.borderStyle = .roundedRect
        self.font = UIFont.systemFont(ofSize: 16)
        self.keyboardType = keyboardType
        self.autocapitalizationType = .none
    }
}
