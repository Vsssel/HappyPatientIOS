//
//  AppointmentCell.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 15.12.2024.
//

import UIKit

class AppointmentCell: UITableViewCell {
    
    static let identifier = "AppointmentCell"
    
    private let doctorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let doctorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        contentView.addSubview(doctorImageView)
        contentView.addSubview(doctorLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(addressLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            doctorImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            doctorImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            doctorImageView.widthAnchor.constraint(equalToConstant: 60),
            doctorImageView.heightAnchor.constraint(equalToConstant: 60),
            
            doctorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            doctorLabel.leadingAnchor.constraint(equalTo: doctorImageView.trailingAnchor, constant: 12),
            doctorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            typeLabel.topAnchor.constraint(equalTo: doctorLabel.bottomAnchor, constant: 4),
            typeLabel.leadingAnchor.constraint(equalTo: doctorImageView.trailingAnchor, constant: 12),
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: doctorImageView.trailingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            addressLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addressLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with appointment: Appointment) {
        doctorLabel.text = "Dr. \(appointment.doctor.name) \(appointment.doctor.surname)"
        typeLabel.text = "Type: \(appointment.type.name)"
        dateLabel.text = "\(appointment.date) | \(formatTime(appointment.startTime) ?? "00:00") - \(formatTime(appointment.endTime) ?? "00:00")"
        addressLabel.text = "Room: \(appointment.room.title), Address: \(appointment.room.address)"
        
        if let url = URL(string: appointment.doctor.avatarUrl) {
            loadImage(from: url)
        } else {
            doctorImageView.image = UIImage(named: "placeholder")
        }

    }
    
    func formatTime(_ time: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        
        if let date = inputFormatter.date(from: time) {
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
    private func loadImage(from url: URL) {
        doctorImageView.image = UIImage(named: "placeholder")
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data),
                  error == nil else { return }
            DispatchQueue.main.async {
                self.doctorImageView.image = image
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        doctorImageView.image = UIImage(named: "placeholder")
        doctorLabel.text = nil
        typeLabel.text = nil
        dateLabel.text = nil
        addressLabel.text = nil
    }
}
