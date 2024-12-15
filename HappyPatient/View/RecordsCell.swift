//
//  RecordsCell.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 15.12.2024.
//

import Foundation
import UIKit
import SnapKit

class RecordsCell: UITableViewCell {
    
    static let identifier = "RecordsCell"
    
    private let doctorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addedTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0 // Allow unlimited lines
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
        let wrapper = UIView()
        wrapper.backgroundColor = .systemBackground
        wrapper.layer.cornerRadius = 10
        wrapper.layer.shadowColor = UIColor.black.cgColor
        wrapper.layer.shadowOpacity = 0.1
        wrapper.layer.shadowOffset = CGSize(width: 0, height: 2)
        wrapper.layer.shadowRadius = 4
        
        wrapper.addSubview(doctorLabel)
        wrapper.addSubview(addedTimeLabel)
        wrapper.addSubview(titleLabel)
        wrapper.addSubview(contentLabel)
        
        contentView.addSubview(wrapper)
        
        wrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        
        doctorLabel.snp.makeConstraints { make in
            make.top.equalTo(wrapper.snp.top).inset(16)
            make.leading.trailing.equalTo(wrapper).inset(16)
        }

        addedTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(doctorLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(wrapper).inset(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(addedTimeLabel.snp.bottom).offset(12)
            make.leading.trailing.equalTo(wrapper).inset(16)
        }

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(wrapper).inset(16)
            make.bottom.equalTo(wrapper).inset(16)
        }
    }
    
    func configure(with record: Page) {
        doctorLabel.text = "\(record.type) by Dr. \(record.doctor.name) \(record.doctor.surname)"
        addedTimeLabel.text = "\(record.addedTime)"
        titleLabel.text = record.title
        contentLabel.text = record.content
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        doctorLabel.text = nil
        addedTimeLabel.text = nil
        titleLabel.text = nil
        contentLabel.text = nil
    }
}
