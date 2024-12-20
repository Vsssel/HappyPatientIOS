//
//  ViewController.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 28.11.2024.
//

import UIKit
import Combine
import SnapKit

class DoctorViewController: UIViewController, UITableViewDelegate {
    private let viewModel = DoctorViewModel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let doctorId: Int?
    public var doctor: Doctor? {
        didSet {
            updateDoctorUI()
        }
    }
    private var cancellables: Set<AnyCancellable> = []
    private lazy var doctorImage: UIImageView = {
        let imageView = createImageView(cornerRadius: 60)
        return imageView
    }()
    private lazy var nameLabel: UILabel = createLabel(text: "Doctor Name", font: .boldSystemFont(ofSize: 18))
    private lazy var makeAppointmentButton: UIButton = createButton(title: "Make Appointment", backgroundColor: .blue)
    private lazy var categoryLabel: UILabel = createLabel(text: "Category", font: .systemFont(ofSize: 16))
    private lazy var experienceLabel: UILabel = createLabel(text: "Experience", font: .systemFont(ofSize: 16))
    private lazy var priceLabel: UILabel = createLabel(text: "Price", font: .systemFont(ofSize: 16))
    private lazy var addressLabel: UILabel = createLabel(text: "Address", font: .systemFont(ofSize: 16))
    private lazy var officeLabel: UILabel = createLabel(text: "Office", font: .systemFont(ofSize: 16))
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let detailsStack = UIStackView()
    private let educationTableView = UITableView(frame: .zero, style: .plain)
    private let experienceTableView = UITableView(frame: .zero, style: .plain)
    private let priceListTableView = UITableView(frame: .zero, style: .plain)
    private lazy var detailsContainer: UIView = createContainerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTables()
        viewModel.getDoctor(id: doctorId!)
        bindViewModel()
    }
    
    init(doctorId: Int) {
        self.doctorId = doctorId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTables() {
        educationTableView.delegate = self
        educationTableView.dataSource = self
        educationTableView.register(UITableViewCell.self, forCellReuseIdentifier: "EducationCell")
        
        experienceTableView.delegate = self
        experienceTableView.dataSource = self
        experienceTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExperienceCell")
        
        priceListTableView.delegate = self
        priceListTableView.dataSource = self
        priceListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PriceListCell")
    }

    
    private func bindViewModel() {
        viewModel.$doctor
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                self?.doctor = success
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingIndicator.isHidden = !isLoading
                isLoading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
                self?.detailsContainer.isHidden = isLoading
            }
            .store(in: &cancellables)
     }
    
    private func updateDoctorUI() {
        guard let doctor = doctor else { return }
        DispatchQueue.main.async { [weak self] in
            self?.nameLabel.text = "\(doctor.name) \(doctor.surname)"
            self?.categoryLabel.text = doctor.category.title
            self?.experienceLabel.text = "\(doctor.expInMonthes / 12) y"
            self?.priceLabel.text = "\(doctor.priceList[0].price) ₸"
            self?.addressLabel.text = String(doctor.office.address)
            self?.officeLabel.text = String(doctor.office.title)
            
            if let url = URL(string: doctor.avatarUrl) {
                self?.loadImage(from: url) { image in
                    self?.doctorImage.image = image
                }
            }
            
            self?.educationTableView.reloadData()
            self?.experienceTableView.reloadData()
            self?.priceListTableView.reloadData()
        }
    }

    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let image = UIImage(data: data)
            DispatchQueue.main.async { completion(image) }
        }
        task.resume()
    }

    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(loadingIndicator)

        view.addSubview(detailsContainer)

        detailsContainer.addSubview(doctorImage)
        detailsContainer.addSubview(nameLabel)

        let categoryView = createIconWithLabel(iconName: "person.text.rectangle", label: categoryLabel)
        let experienceView = createIconWithLabel(iconName: "clock", label: experienceLabel)
        let priceView = createIconWithLabel(iconName: "dollarsign.circle", label: priceLabel)
        let firstRowStack = createHorizontalStack(views: [categoryView, experienceView, priceView], spacing: 16)
        let addressView = createIconWithLabel(iconName: "map", label: addressLabel)
        let officeView = createIconWithLabel(iconName: "building.2", label: officeLabel)
        let secondRowStack = createHorizontalStack(views: [addressView, officeView], spacing: 16)

        let verticalStack = createVerticalStack(views: [firstRowStack, secondRowStack], spacing: 16)
        detailsContainer.addSubview(verticalStack)

        detailsContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        doctorImage.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 120, height: 120))
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(doctorImage.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }


        verticalStack.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        let tableStack = createVerticalStack(views: [educationTableView, experienceTableView, priceListTableView], spacing: 16)
        detailsContainer.addSubview(tableStack)

        tableStack.snp.makeConstraints { make in
            make.top.equalTo(verticalStack.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(1)
        }

        educationTableView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        experienceTableView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        priceListTableView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        detailsContainer.addSubview(makeAppointmentButton)
        makeAppointmentButton.snp.makeConstraints { make in
            make.top.equalTo(priceListTableView.snp.bottom).offset(26)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(16)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        makeAppointmentButton.addTarget(self, action: #selector(makeAppointment), for: .touchUpInside)

    }

    private func createIconWithLabel(iconName: String, label: UILabel) -> UIView {
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .gray
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        label.textAlignment = .left
        let horizontalStack = createHorizontalStack(views: [iconImageView, label], spacing: 4)
        return horizontalStack
    }


    private func createButton(title: String, backgroundColor: UIColor = .clear, textColor: UIColor = .white, action: Selector? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowRadius = 10
        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        return button
    }

    private func createContainerView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 6
        return view
    }
    
    private func createLabel(text: String, font: UIFont, alignment: NSTextAlignment = .natural) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textAlignment = alignment
        return label
    }
    
    private func createImageView(image: UIImage? = nil, contentMode: UIView.ContentMode = .scaleAspectFill, cornerRadius: CGFloat = 0) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = cornerRadius
        return imageView
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
    
    private func updateUI(with doctor: Doctor) {
        nameLabel.text = "\(doctor.name) \(doctor.surname)"
        doctorImage.image = UIImage(named: doctor.avatarUrl) // Adjust as needed
        tableView.reloadData()
    }
    
    @objc private func makeAppointment() {
        let makeAppointmentVC = MakeAppointmentViewController()
        makeAppointmentVC.doctor = doctor

        makeAppointmentVC.modalPresentationStyle = .pageSheet
        makeAppointmentVC.modalTransitionStyle = .coverVertical

        if let sheet = makeAppointmentVC.sheetPresentationController {
            sheet.detents = [.custom { context in
                return UIScreen.main.bounds.height * 0.3
            }]
            sheet.prefersGrabberVisible = true
        }

        present(makeAppointmentVC, animated: true, completion: nil)
    }

}

extension DoctorViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let doctor = doctor else { return 0 }
            if tableView == educationTableView {
                return doctor.education.count
            } else if tableView == experienceTableView {
                return doctor.experience.count
            } else if tableView == priceListTableView {
                return doctor.priceList.count
            }
            return 0
        }
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            if tableView == educationTableView {
                return "Education"
            } else if tableView == experienceTableView {
                return "Experience"
            } else if tableView == priceListTableView {
                return "Price List"
            }
            return nil
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == educationTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EducationCell", for: indexPath)
            guard let doctor = doctor else { return cell }
            let education = doctor.education[indexPath.row]
            cell.textLabel?.text = "\(education.organization) (\(education.startYear) - \(education.endYear)) GPA: \(education.gpa)/\(education.gpaFrom)"
            return cell
        } else if tableView == experienceTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExperienceCell", for: indexPath)
            guard let doctor = doctor else { return cell }
            let experience = doctor.experience[indexPath.row]
            cell.textLabel?.text = "\(experience.organization) - \(experience.position) (\(experience.startDate) - \(experience.endDate))"
            return cell
        } else if tableView == priceListTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PriceListCell", for: indexPath)
            guard let doctor = doctor else { return cell }
            let price = doctor.priceList[indexPath.row]
            cell.textLabel?.text = "\(price.typeName) - \(price.price) ₸"
            return cell
        }
        return UITableViewCell()
    }

}
