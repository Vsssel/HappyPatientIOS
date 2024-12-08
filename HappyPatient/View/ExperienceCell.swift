//
//  ExperienceCell.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 04.12.2024.
//

import Foundation
import UIKit

class ExperienceCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let positionLabel = UILabel()
    private let dateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(positionLabel)
        contentView.addSubview(dateLabel)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        positionLabel.font = UIFont.systemFont(ofSize: 14)
        positionLabel.textColor = .gray
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .lightGray

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        positionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(positionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    func configure(with experience: Experience) {
        titleLabel.text = experience.organization
        positionLabel.text = experience.position
        dateLabel.text = "\(experience.startDate) - \(experience.endDate)"
    }
}
