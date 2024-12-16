//
//  SearchViewController.swift
//  HappyPatient
//
//  Created by Aldongarov Nuraskhan on 15.12.2024.
//

import Foundation
import UIKit
import SnapKit
import Alamofire

class SearchViewController: UIViewController {
    private let fullnameTextField = UITextField()
    private let minExpYearsTextField = UITextField()
    private let categoriesTextField = UITextField()
    private let officesTextField = UITextField()
    private let sortBySegmentControl = UISegmentedControl(items: ["Name", "Experience"])
    private let ascOrderSwitch = UISwitch()
    private let ascOrderLabel = UILabel()
    private let applyFiltersButton = UIButton(type: .system)
    private let resultsTableView = UITableView()
    private let extendedSearchButton = UIButton(type: .system)

    private let searchTextField = UITextField()
    
    private var doctors: [Doctor] = []

    private let filtersContainer = UIView()
    private let searchContainerView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        fetchDoctors()
        updateTableViewConstraints()
        
    }

    private func setupUI() {
        fullnameTextField.placeholder = "Search..."
        fullnameTextField.borderStyle = .roundedRect
        fullnameTextField.clearButtonMode = .whileEditing
        fullnameTextField.backgroundColor = .systemGray6
        fullnameTextField.layer.cornerRadius = 12
        fullnameTextField.layer.masksToBounds = true

        let searchButton = createStyledButton(
            title: nil,
            backgroundColor: .systemBlue,
            icon: UIImage(systemName: "magnifyingglass"),
            action: #selector(searchAction)
        )
        
        let extendedSearchButton = createStyledButton(
            title: nil,
            backgroundColor: .systemGray,
            icon: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            action: #selector(toggleFiltersVisibility)
        )
        
        searchContainerView.addSubview(fullnameTextField)
        searchContainerView.addSubview(extendedSearchButton)
        searchContainerView.addSubview(searchButton)
        view.addSubview(searchContainerView)
        searchContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.equalTo(view).inset(16)
            make.right.equalTo(view).inset(16)
            make.height.equalTo(50)
            
        }

        fullnameTextField.snp.makeConstraints { make in
            make.top.bottom.equalTo(searchContainerView)
            make.left.equalTo(searchContainerView).offset(8)
            make.right.equalTo(extendedSearchButton.snp.left).offset(-8)
            
        }

        searchButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(searchContainerView)
            make.right.equalTo(searchContainerView.snp.right).offset(8)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }

        extendedSearchButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(searchContainerView)
            make.width.height.equalTo(50)
            make.right.equalTo(searchContainerView).offset(-50)
        }

        view.addSubview(filtersContainer)
        filtersContainer.snp.makeConstraints { make in
            make.top.equalTo(extendedSearchButton.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(300)
            
        }

        filtersContainer.alpha = 0.0

        minExpYearsTextField.placeholder = "Min experience years"
        minExpYearsTextField.borderStyle = .roundedRect
        minExpYearsTextField.keyboardType = .numberPad
        filtersContainer.addSubview(minExpYearsTextField)
        minExpYearsTextField.snp.makeConstraints { make in
            make.top.equalTo(filtersContainer.snp.top)
            make.left.right.equalTo(filtersContainer).inset(16)
            make.height.equalTo(40)
        }

        categoriesTextField.placeholder = "Enter categories (comma-separated)"
        categoriesTextField.borderStyle = .roundedRect
        filtersContainer.addSubview(categoriesTextField)
        categoriesTextField.snp.makeConstraints { make in
            make.top.equalTo(minExpYearsTextField.snp.bottom).offset(16)
            make.left.right.equalTo(filtersContainer).inset(16)
            make.height.equalTo(40)
        }

        officesTextField.placeholder = "Enter offices (comma-separated)"
        officesTextField.borderStyle = .roundedRect
        filtersContainer.addSubview(officesTextField)
        officesTextField.snp.makeConstraints { make in
            make.top.equalTo(categoriesTextField.snp.bottom).offset(16)
            make.left.right.equalTo(filtersContainer).inset(16)
            make.height.equalTo(40)
        }

        filtersContainer.addSubview(sortBySegmentControl)
        sortBySegmentControl.selectedSegmentIndex = 0
        sortBySegmentControl.snp.makeConstraints { make in
            make.top.equalTo(officesTextField.snp.bottom).offset(16)
            make.left.right.equalTo(filtersContainer).inset(16)
        }

        filtersContainer.addSubview(ascOrderLabel)
        ascOrderLabel.text = "Ascending Order"
        ascOrderLabel.font = .systemFont(ofSize: 16)
        ascOrderLabel.snp.makeConstraints { make in
            make.top.equalTo(sortBySegmentControl.snp.bottom).offset(16)
            make.left.equalTo(filtersContainer).inset(16)
        }

        filtersContainer.addSubview(ascOrderSwitch)
        ascOrderSwitch.isOn = true
        ascOrderSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(ascOrderLabel)
            make.left.equalTo(ascOrderLabel.snp.right).offset(8)
        }

        filtersContainer.addSubview(applyFiltersButton)
        applyFiltersButton.setTitle("Apply Filters", for: .normal)
        applyFiltersButton.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
        applyFiltersButton.snp.makeConstraints { make in
            make.top.equalTo(ascOrderSwitch.snp.bottom).offset(16)
            make.centerX.equalTo(filtersContainer)
            make.height.equalTo(50)
            make.width.equalTo(150)
        }

        resultsTableView.register(DoctorCell.self, forCellReuseIdentifier: "DoctorCell")
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        view.addSubview(resultsTableView)
        resultsTableView.snp.makeConstraints { make in
            make.top.equalTo(filtersContainer.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
    }


    @objc private func applyFilters() {
        UIView.animate(withDuration: 0.3){
            self.fetchDoctors()
            self.resultsTableView.reloadData()
            self.toggleFiltersVisibility()
        }
        
        
    }
    private func createStyledButton(title: String?, backgroundColor: UIColor, icon: UIImage?, action: Selector) -> UIButton {
            let button = UIButton(type: .system)
            if let title = title {
                button.setTitle(title, for: .normal)
                button.setTitleColor(.white, for: .normal)
            }
            if let icon = icon {
                button.setImage(icon, for: .normal)
                button.tintColor = .white
            }
            button.backgroundColor = backgroundColor
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.layer.cornerRadius = 12
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowOpacity = 0.2
            button.layer.shadowRadius = 4
            button.addTarget(self, action: action, for: .touchUpInside)
            return button
        }
    @objc private func searchAction() {
        UIView.animate(withDuration: 0.3){
            self.fetchDoctors()
        }
        
        
    }
    @objc private func toggleFiltersVisibility() {
        UIView.animate(withDuration: 0.3, animations: {
                if self.filtersContainer.alpha == 0.0 {
                    self.filtersContainer.alpha = 1.0
                } else {
                    self.filtersContainer.alpha = 0.0
                }
            }, completion: { _ in
                self.updateTableViewConstraints()
            })
    }
    private func updateTableViewConstraints() {
        resultsTableView.snp.remakeConstraints { make in
            if self.filtersContainer.alpha == 0.0 {
                make.top.equalTo(self.searchContainerView.snp.bottom).offset(16)
            } else {
                make.top.equalTo(self.filtersContainer.snp.bottom).offset(16)
            }
            make.left.right.bottom.equalToSuperview()
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    private func fetchDoctors() {
            let baseURL = "http://64.225.71.203:2222/patient/doctors"
            var parameters: [String: Any] = [:]

            if let fullname = fullnameTextField.text, !fullname.isEmpty {
                parameters["fullname"] = fullname
            }

            if let minExpYearsText = minExpYearsTextField.text, !minExpYearsText.isEmpty {
                if let minExpYears = Int(minExpYearsText) {
                    parameters["min_exp_years"] = minExpYears
                } else {
                    print("Invalid input for min_exp_years")
                    return
                }
            }

            if let categories = categoriesTextField.text, !categories.isEmpty {
                let categoryIDs = categories.split(separator: ",").map { String($0) }
                parameters["categories[]"] = categoryIDs
            }

            if let offices = officesTextField.text, !offices.isEmpty {
                let officeIDs = offices.split(separator: ",").map { String($0) }
                parameters["offices[]"] = officeIDs
            }

            let sortBy = sortBySegmentControl.selectedSegmentIndex == 0 ? "name" : "experience"
            parameters["sort_by"] = sortBy
            parameters["asc_order"] = ascOrderSwitch.isOn ? "true" : "false"

            AF.request(baseURL, method: .get, parameters: parameters)
                .validate()
                .responseJSON { [weak self] response in
                    guard let self = self else { return }
                    
                    switch response.result {
                    case .success(let data):
                        do {
                            let decoder = JSONDecoder()
                            let tempDoctors = try decoder.decode([TempDoctor].self, from: response.data ?? Data())
                            let doctors:[Doctor] = tempDoctors.map { tempDoctor in
                                    Doctor(
                                        id: tempDoctor.id,
                                        name: tempDoctor.name,
                                        surname: tempDoctor.surname,
                                        avatarUrl: tempDoctor.avatarUrl,
                                        age: tempDoctor.age,
                                        expInMonthes: tempDoctor.expInMonthes,
                                        category: tempDoctor.category,
                                        office: tempDoctor.office,
                                        priceList: [],
                                        experience: [],
                                        education: []

                                    )
                                }
                            print("****")
                            DispatchQueue.main.async {
                                self.doctors = doctors
                                self.resultsTableView.reloadData()
                            }
                        } catch {
                            print("Error decoding: \(error)")
                        }
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
        }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorCell", for: indexPath) as! DoctorCell
        let doctor = doctors[indexPath.row]
        cell.configure(with: doctor)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let doctorVC = DoctorViewController(doctorId: doctors[indexPath.row].id)
        navigationController?.pushViewController(DoctorViewController(doctorId: doctors[indexPath.row].id), animated: true)
    }

}
