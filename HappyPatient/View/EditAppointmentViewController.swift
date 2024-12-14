//
//  EditAppointmentViewController.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 15.12.2024.
//

import UIKit

class EditAppointmentViewController: UIViewController {
    
    var appointment: Appointment
    var onSave: ((Appointment) -> Void)?
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    init(appointment: Appointment) {
        self.appointment = appointment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(textField)
        textField.text = appointment.doctor.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textField.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    @objc private func saveTapped() {
        let updatedAppointment = Appointment(
            id: appointment.id,
            index: appointment.index,
            date: appointment.date,
            startTime: appointment.startTime,
            endTime: appointment.endTime,
            price: appointment.price,
            isFinished: appointment.isFinished,
            isPaid: appointment.isPaid,
            type: appointment.type,
            category: appointment.category,
            room: appointment.room,
            doctor: DoctorInfo(id: appointment.doctor.id, name: textField.text ?? "", surname: appointment.doctor.surname, avatarUrl: appointment.doctor.avatarUrl)
        )
        onSave?(updatedAppointment)
        dismiss(animated: true, completion: nil)
    }
}
