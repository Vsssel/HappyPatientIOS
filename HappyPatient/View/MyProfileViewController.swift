import UIKit
import Combine
import SnapKit

class MyProfileViewController: UIViewController {
    
    private let viewModel = MyProfileViewModel()
    private var user: User? {
        didSet {
            updateUI(with: user)
        }
    }
    private var cancellables: Set<AnyCancellable> = []

    private let contentView = UIView()

    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let birthDateLabel = UILabel()
    private let emailLabel = UILabel()

    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let logoutButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.getUser()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        profileImageView.image = UIImage(systemName: "person.circle")
        profileImageView.tintColor = .systemGray
        profileImageView.contentMode = .scaleAspectFit
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
            make.size.equalTo(150)
        }

        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .label
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        birthDateLabel.font = .systemFont(ofSize: 16)
        birthDateLabel.textAlignment = .center
        birthDateLabel.textColor = .secondaryLabel
        contentView.addSubview(birthDateLabel)
        birthDateLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        emailLabel.font = .systemFont(ofSize: 16)
        emailLabel.textAlignment = .center
        emailLabel.textColor = .secondaryLabel
        contentView.addSubview(emailLabel)
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(birthDateLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = .systemBlue
        logoutButton.layer.cornerRadius = 8
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        contentView.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(44)
        }

        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupBindings() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingIndicator.isHidden = !isLoading
                isLoading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
                self?.logoutButton.isHidden = isLoading
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let errorMessage = errorMessage else { return }
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func updateUI(with user: User?) {
        guard let user = user else { return }
        nameLabel.text = "\(user.name) \(user.surname)"
        birthDateLabel.text = "Birth Date: \(user.birthDate)"
        emailLabel.text = "Email: \(user.email)"
    }

    @objc private func logoutButtonTapped() {
        AuthenticationManager.shared.clearToken()
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion: nil)
    }
}
