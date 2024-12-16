//
//  DoctorCell.swift
//  SearchBar
//
//  Created by Aldongarov Nuraskhan on 15.12.2024.
//

import Foundation

import UIKit

class DoctorCell: UITableViewCell {

    // UI Elements
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let experienceLabel = UILabel()
    private let priceLabel = UILabel()
    private let appointmentButton = UIButton()

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // Avatar Image
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(80)
        }

        // Name Label
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.top)
            make.left.equalTo(avatarImageView.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        // Category Label
        categoryLabel.font = UIFont.systemFont(ofSize: 14)
        categoryLabel.textColor = .gray
        contentView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(nameLabel.snp.right)
        }

        // Experience Label
        experienceLabel.font = UIFont.systemFont(ofSize: 14)
        experienceLabel.textColor = .gray
        contentView.addSubview(experienceLabel)
        experienceLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(nameLabel.snp.right)
        }

        // Price Label
        priceLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(experienceLabel.snp.bottom).offset(8)
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(nameLabel.snp.right)
        }

        // Appointment Button
        appointmentButton.setTitle("Book Appointment", for: .normal)
        appointmentButton.setTitleColor(.blue, for: .normal)
        appointmentButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(appointmentButton)
        appointmentButton.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
            make.left.equalTo(nameLabel.snp.left)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    // MARK: - Configure Cell
    func configure(with doctor: Doctor) {
        // Set the avatar image (you might want to load the image from a URL)
        if let url = URL(string: doctor.avatarUrl) {
            avatarImageView.loadImage(from: url) // Use an image loading extension or library like SDWebImage or Kingfisher
        }

        // Set the doctor's info
        nameLabel.text = "\(doctor.name) \(doctor.surname)"
        categoryLabel.text = "Category: \(doctor.category.title)"
        experienceLabel.text = "Experience: \(doctor.expInMonthes / 12) years"
        
        // Assuming the doctor has a price list and you want to show the first price
        

        // Handle appointment button action (you could use a delegate or closure to handle it)
        appointmentButton.addTarget(self, action: #selector(bookAppointment), for: .touchUpInside)
    }

    @objc private func bookAppointment() {
        // Handle the appointment booking (you might use a delegate or closure to inform the parent controller)
        print("Book appointment with \(nameLabel.text ?? "")")
        let appointmentViewController = AppointmentsViewController() // Initialize the next view controller
        // Present the new view controller modally
        
    }
}

// MARK: - UIImageView Extension (to load image from URL)
extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}
