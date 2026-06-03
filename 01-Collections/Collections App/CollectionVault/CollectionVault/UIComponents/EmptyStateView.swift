//
//  EmptyStateView.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import UIKit

final class EmptyStateView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title2)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    init(iconName: String, title: String, description: String? = nil) {
        super.init(frame: .zero)
        setupView()
        configure(iconName: iconName, title: title, description: description)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(iconImageView)
        addSubview(messageLabel)
        addSubview(descriptionLabel)
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            messageLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: CVDesign.Spacing.spacing400),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CVDesign.Spacing.spacing600),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CVDesign.Spacing.spacing600),
            
            descriptionLabel.topAnchor.constraint(equalToSystemSpacingBelow: messageLabel.bottomAnchor, multiplier: 1),
            descriptionLabel.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor)
        ])
    }
    
    func configure(iconName: String, title: String, description: String?) {
        iconImageView.image = UIImage(systemName: iconName)
        messageLabel.text = title
        descriptionLabel.text = description
    }
}
