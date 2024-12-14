import UIKit
import Foundation
import Combine

class AppointmentsViewController: UIViewController {
    
    private var appointments: [Appointment] = []
    private var filteredAppointments: [Appointment] = []
    private var viewModel = AppointmentsViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formatter
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AppointmentCell.self, forCellReuseIdentifier: AppointmentCell.identifier)
        tableView.rowHeight = 120
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Upcoming", "Past"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor.systemGray6
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.getAppointments()
        
        title = "My Appointments"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.getAppointments()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalTo(view).inset(20)
            make.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
           make.leading.equalTo(view.snp.leading)
           make.trailing.equalTo(view.snp.trailing)
           make.bottom.equalTo(view.snp.bottom)
       }
    }
    
    private func setupBindings() {
        viewModel.$appointments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] appointments in
                guard let self = self else { return }
                self.appointments = appointments ?? []
                self.filterAndSortAppointments()
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
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        filterAndSortAppointments()
    }
    
    private func filterAndSortAppointments() {
        let currentDate = Date.now
        filteredAppointments = appointments.filter { appointment in
            let fullDateString = "\(appointment.date) \(appointment.startTime)"
            if let appointmentDateTime = dateFormatter.date(from: fullDateString) {
                return segmentedControl.selectedSegmentIndex == 0 ? appointmentDateTime > currentDate : appointmentDateTime <= currentDate
            }
            return false
        }
        
        tableView.reloadData()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func editAppointment(at indexPath: IndexPath) {
        let appointment = filteredAppointments[indexPath.row]
        let editViewController = EditAppointmentViewController(appointment: appointment)
        
        editViewController.modalPresentationStyle = .formSheet
        editViewController.onSave = { [weak self] updatedAppointment in
            guard let self = self else { return }
            self.appointments[indexPath.row] = updatedAppointment
            self.filterAndSortAppointments()
        }
        present(editViewController, animated: true)
    }
    
    private func deleteAppointment(at indexPath: IndexPath) {
        let appointment = filteredAppointments[indexPath.row]
        let fullDateString = "\(appointment.date) \(appointment.startTime)"
        
        if let appointmentDateTime = dateFormatter.date(from: fullDateString), Date.now > appointmentDateTime {
            showErrorAlert(message: "You cannot delete past appointments")
            return
        }
        viewModel.deleteAppointment(id: appointment.id) { [weak self] success in
            guard let self = self else { return }
            if success {
                viewModel.getAppointments()
                self.filterAndSortAppointments()
            } else {
                self.showErrorAlert(message: "Failed to delete the appointment.")
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AppointmentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAppointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AppointmentCell.identifier, for: indexPath) as! AppointmentCell
        cell.configure(with: filteredAppointments[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let appointment = filteredAppointments[indexPath.row]
        let fullDateString = "\(appointment.date) \(appointment.startTime)"
        
        if let appointmentDateTime = dateFormatter.date(from: fullDateString), Date.now > appointmentDateTime {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            self.deleteAppointment(at: indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            self.editAppointment(at: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}
