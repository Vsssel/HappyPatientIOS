//
//  EducationCell.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 04.12.2024.
//

import UIKit

class EducationCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let gpaLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(gpaLabel)
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        gpaLabel.font = UIFont.systemFont(ofSize: 14)
        gpaLabel.textColor = .gray
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        gpaLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    func configure(with education: Education) {
        titleLabel.text = "\(education.organization) (\(education.startYear) - \(education.endYear))"
        gpaLabel.text = "GPA: \(education.gpa)/\(education.gpaFrom)"
    }
}
