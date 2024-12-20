//
//  EditAppointmentViewController.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 15.12.2024.
//

import UIKit
import Foundation
import Combine

class EditAppointmentViewController: UIViewController {
    
    var appointment: Appointment
    private let viewModel = EditAppointmentViewModel()
    public var slots: Slots?
    private var cancellables: Set<AnyCancellable> = []
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    private var selectedOption = 30
    private var selectedSlot: FreeSLots? {
        didSet {
            freeSlotsCollectionView.reloadData()
        }
    }
    var onSave: ((Bool) -> Void)?
    
    init(appointment: Appointment) {
        self.appointment = appointment
        selectedOption = self.appointment.type.id == 1 ? 30 : 60
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var selectorSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Visit", "Treatment"])
        segmentedControl.selectedSegmentIndex = appointment.type.id - 1
        segmentedControl.backgroundColor = UIColor.systemGray6
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        segmentedControl.addTarget(self, action: #selector(selectorChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.date = dateFormatter.date(from: appointment.date)!
        picker.datePickerMode = .date
        picker.minimumDate = .now
        picker.maximumDate = Date().addingTimeInterval(3 * 7 * 24 * 60 * 60)
        picker.tintColor = UIColor.systemBlue
        picker.layer.cornerRadius = 10
        picker.backgroundColor = UIColor.systemGray6
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var freeSlotsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 100, height: 40)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(FreeSlotCell.self, forCellWithReuseIdentifier: FreeSlotCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var bookAppointmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Appointment", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowRadius = 10
        button.addTarget(self, action: #selector(editAppointment), for: .touchUpInside)
        return button
    }()
    
    private lazy var noSlotsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Free Slots"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .gray
        label.isHidden = true // Initially hidden
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        fetchSlots(for: datePicker.date)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(selectorSegmentedControl)
        view.addSubview(datePicker)
        view.addSubview(freeSlotsCollectionView)
        view.addSubview(noSlotsLabel)
        view.addSubview(bookAppointmentButton)
        
        selectorSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalTo(view).inset(20)
            make.height.equalTo(40)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(selectorSegmentedControl.snp.bottom).offset(20)
            make.centerX.equalTo(view)
        }
        
        freeSlotsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view).inset(20)
            make.height.equalTo(50)
        }
        
        bookAppointmentButton.snp.makeConstraints { make in
            make.top.equalTo(freeSlotsCollectionView.snp.bottom).offset(20)
            make.centerX.equalTo(view)
            make.height.equalTo(44)
            make.width.equalTo(200)
        }
        
        noSlotsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        viewModel.$slots
            .receive(on: DispatchQueue.main)
            .sink { [weak self] slots in
                self?.slots = slots
                self?.freeSlotsCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showErrorAlert(title: "Error", message: error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchSlots(for date: Date) {
        let formattedDate = dateFormatter.string(from: date)
        viewModel.getFreeSlots(id: appointment.doctor.id, date: formattedDate, except_slot_id: nil, duration: selectedOption, min_interval: nil)
    }
    
    private func showErrorAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    @objc private func selectorChanged() {
        selectedOption = selectorSegmentedControl.selectedSegmentIndex == 0 ? 30 : 60
        fetchSlots(for: datePicker.date)
    }
    
    @objc private func dateChanged() {
        fetchSlots(for: datePicker.date)
    }
    
    @objc private func editAppointment() {
        guard let slot = selectedSlot else {
            showErrorAlert(title: "Error", message: "Please select a free slot.")
            return
        }
        
        let selectedDate = dateFormatter.string(from: datePicker.date)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let startsAt = timeFormatter.string(from: timeFormatter.date(from: slot.startTime)!)
        let endsAt = timeFormatter.string(from: timeFormatter.date(from: slot.endTime)!)
        
        viewModel.putAppointment(id: appointment.id, doctorId: appointment.doctor.id, date: selectedDate, typeId: selectedOption == 30 ? 1 : 2, startsAt: startsAt, endsAt: endsAt)
        
        onSave?(true)
        
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if !isLoading, let errorMessage = self.viewModel.errorMessage {
                    self.showErrorAlert(title: "Error", message: errorMessage)
                } else if !isLoading && self.viewModel.errorMessage == nil {
                    self.showErrorAlert(title: "Success", message: "Appointment edited successfully.") {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            .store(in: &cancellables)
    }

}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension EditAppointmentViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let hasFreeSlots = slots?.freeSlots.count ?? 0
        collectionView.isHidden = hasFreeSlots == 0
        noSlotsLabel.isHidden = hasFreeSlots != 0
        return hasFreeSlots
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FreeSlotCell.identifier, for: indexPath) as! FreeSlotCell
        if let slot = slots?.freeSlots[indexPath.item] {
            cell.configure(with: slot, isSelected: slot == selectedSlot)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSlot = slots?.freeSlots[indexPath.item]
    }
}
