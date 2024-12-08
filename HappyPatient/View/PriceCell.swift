//
//  PriceCell.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 04.12.2024.
//

import Foundation
import UIKit

class PriceCell: UITableViewCell {
    private let priceLabel = UILabel()
    private let typeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(typeLabel)
        contentView.addSubview(priceLabel)
        
        typeLabel.font = UIFont.systemFont(ofSize: 16)
        priceLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.textColor = .blue

        typeLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    func configure(with price: PriceList) {
        typeLabel.text = price.typeName
        priceLabel.text = "Price: \(price.price)₸"
    }
}
