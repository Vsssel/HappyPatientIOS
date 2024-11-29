import UIKit
import SnapKit

class EmailConfirmationViewController: UIViewController {
    
    private let birthDateTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let verificationCodeTextField = UITextField()
    private let genderSegmentedControl = UISegmentedControl(items: ["Male", "Female"])
    private let completeSignUpButton = UIButton(type: .system)
    private let mainStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [birthDateTextField, passwordTextField, confirmPasswordTextField, verificationCodeTextField].forEach {
            $0.borderStyle = .roundedRect
            $0.font = UIFont.systemFont(ofSize: 16)
        }
        
        birthDateTextField.placeholder = "Birth Date"
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.placeholder = "Confirm Password"
        confirmPasswordTextField.isSecureTextEntry = true
        verificationCodeTextField.placeholder = "Verification Code"
        
        genderSegmentedControl.selectedSegmentIndex = 0
        
        completeSignUpButton.setTitle("Complete Sign Up", for: .normal)
        completeSignUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        completeSignUpButton.backgroundColor = .systemBlue
        completeSignUpButton.tintColor = .white
        completeSignUpButton.layer.cornerRadius = 8
        completeSignUpButton.addTarget(self, action: #selector(completeSignUpButtonTapped), for: .touchUpInside)
        
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        view.addSubview(mainStack)
        
        mainStack.addArrangedSubview(birthDateTextField)
        mainStack.addArrangedSubview(passwordTextField)
        mainStack.addArrangedSubview(confirmPasswordTextField)
        mainStack.addArrangedSubview(verificationCodeTextField)
        mainStack.addArrangedSubview(genderSegmentedControl)
        mainStack.addArrangedSubview(completeSignUpButton)
        
        mainStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.left.right.equalToSuperview().inset(16)
        }
        
        completeSignUpButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
    }
    
    @objc private func completeSignUpButtonTapped() {
        // Handle sign-up completion
    }
}
