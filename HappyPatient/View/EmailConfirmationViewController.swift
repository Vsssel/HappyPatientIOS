import UIKit
import SnapKit
import Combine

class EmailConfirmationViewController: UIViewController {
    
    private let birthDatePicker = UIDatePicker()
    private let birthdayLabel = UILabel()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let verificationCodeTextField = UITextField()
    private let genderSegmentedControl = UISegmentedControl(items: ["Male", "Female"])
    private let completeSignUpButton = UIButton(type: .system)
    private let backButton = UIButton()
    private let mainStack = UIStackView()
    private let contentView = UIView()
    private let viewModel = SignUpViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
       formatter.dateFormat = "dd-MM-yyyy"
       return formatter
   }()
    
    var user: TempUserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupDatePicker()
        setupTextFields()
        setupButtons()
        setupMainStack()
        setupContentView()
        setupBindings()
    }
    
    private func setupDatePicker() {
        birthdayLabel.text = "Date of Birth"
        birthdayLabel.font = .systemFont(ofSize: 16, weight: .regular)
        
        birthDatePicker.maximumDate = .now
        birthDatePicker.datePickerMode = .date
        birthDatePicker.preferredDatePickerStyle = .compact
    }
    
    private func setupTextFields() {
        [passwordTextField, confirmPasswordTextField, verificationCodeTextField].forEach {
            $0.borderStyle = .roundedRect
            $0.font = UIFont.systemFont(ofSize: 16)
        }
        
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        addPasswordToggle(to: passwordTextField)
        
        confirmPasswordTextField.placeholder = "Confirm Password"
        confirmPasswordTextField.isSecureTextEntry = true
        addPasswordToggle(to: confirmPasswordTextField)
        
        verificationCodeTextField.placeholder = "Verification Code"
    }
    
    private func setupButtons() {
        completeSignUpButton.setTitle("Complete Sign Up", for: .normal)
        completeSignUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        completeSignUpButton.backgroundColor = .systemBlue
        completeSignUpButton.tintColor = .white
        completeSignUpButton.layer.cornerRadius = 8
        completeSignUpButton.addTarget(self, action: #selector(completeSignUpButtonTapped), for: .touchUpInside)
        
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        backButton.backgroundColor = .systemBlue
        backButton.tintColor = .white
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(buttonBackTapped), for: .touchUpInside)
    }
    
    private func setupMainStack() {
        let dateStack = UIStackView(arrangedSubviews: [birthdayLabel, birthDatePicker])
        dateStack.axis = .horizontal
        dateStack.spacing = 8
        dateStack.distribution = .fillEqually
        
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        
        mainStack.addArrangedSubview(dateStack)
        mainStack.addArrangedSubview(passwordTextField)
        mainStack.addArrangedSubview(confirmPasswordTextField)
        mainStack.addArrangedSubview(verificationCodeTextField)
        mainStack.addArrangedSubview(genderSegmentedControl)
        mainStack.addArrangedSubview(completeSignUpButton)
        mainStack.addArrangedSubview(backButton)
    }
    
    private func setupContentView() {
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
    
    @objc private func completeSignUpButtonTapped() {
        guard let user = user else { return }

        guard !dateFormatter.string(from: birthDatePicker.date).isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let passwordConfirmation = confirmPasswordTextField.text, !passwordConfirmation.isEmpty,
              genderSegmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment,
              let verificationCode = verificationCodeTextField.text, !verificationCode.isEmpty else {
            showErrorAlert(message: "Please fill in all fields.")
            return
        }

        if password != passwordConfirmation {
            showErrorAlert(message: "Passwords do not match.")
            return
        }

        let gender = genderSegmentedControl.selectedSegmentIndex == 0 ? "male" : "female"

        let params = SignUpRequest(
            name: user.name,
            surname: user.surname,
            email: user.email,
            iin: user.iin,
            gender: gender,
            birthDate: dateFormatter.string(from: birthDatePicker.date),
            emailVerificationCode: Int(verificationCode)!,
            password: password
        )

        viewModel.signUp(params: params)
    }
    
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.completeSignUpButton.isEnabled = !isLoading
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
        
        viewModel.$signedUp
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                guard success == true else { return }
                let viewVC = DoctorViewController()
                viewVC.modalPresentationStyle = .fullScreen
                self?.present(viewVC, animated: true)
            }
            .store(in: &cancellables)
    }

    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    @objc private func buttonBackTapped() {
        dismiss(animated: true)
    }
    
    private func addPasswordToggle(to textField: UITextField) {
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        toggleButton.tintColor = .gray
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        textField.rightView = toggleButton
        textField.rightViewMode = .always
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        guard let textField = sender.superview as? UITextField else { return }
        textField.isSecureTextEntry.toggle()
        let buttonImage = textField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: buttonImage), for: .normal)
    }
}
