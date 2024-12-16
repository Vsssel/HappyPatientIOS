//
//  DoctorCell.swift
//  SearchBar
//
//  Created by Aldongarov Nuraskhan on 15.12.2024.
//

import Foundation

import UIKit

class DoctorCell: UITableViewCell {
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let experienceLabel = UILabel()
    private let priceLabel = UILabel()
    private let appointmentButton = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(80)
        }

        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.top)
            make.left.equalTo(avatarImageView.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        categoryLabel.font = UIFont.systemFont(ofSize: 14)
        categoryLabel.textColor = .gray
        contentView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(nameLabel.snp.right)
        }

        experienceLabel.font = UIFont.systemFont(ofSize: 14)
        experienceLabel.textColor = .gray
        contentView.addSubview(experienceLabel)
        experienceLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(nameLabel.snp.right)
        }

        priceLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(experienceLabel.snp.bottom).offset(8)
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(nameLabel.snp.right)
            make.bottom.equalToSuperview().offset(-8)
        }

    }

    func configure(with doctor: Doctor) {
        if let url = URL(string: doctor.avatarUrl) {
            avatarImageView.loadImage(from: url)
        }

        nameLabel.text = "\(doctor.name) \(doctor.surname)"
        categoryLabel.text = "Category: \(doctor.category.title)"
        experienceLabel.text = "Experience: \(doctor.expInMonthes / 12) years"
        appointmentButton.addTarget(self, action: #selector(bookAppointment), for: .touchUpInside)
    }

    @objc private func bookAppointment() {
        print("Book appointment with \(nameLabel.text ?? "")")
        let appointmentViewController = AppointmentsViewController()
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
