//
//  AttachmentDetailCell.swift
//  Files
//
//  Created by MAHESHWARAN on 04/06/23.
//

import Foundation
import UIKit

class AttachmentDetailCell: UITableViewCell {
  
  static let reuseIdentifier = "AttachmentDetailCell"
  
  // MARK: - Outlets
  
  lazy var containerView: UIView = {
    $0.backgroundColor = .systemGroupedBackground
    $0.setContentHuggingPriority(.required, for: .vertical)
    $0.translatesAutoresizingMaskIntoConstraints = false
    return $0
  }(UIView())
  
  private lazy var imageDetailView: UIImageView = {
    $0.contentMode = .scaleToFill
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.layer.cornerRadius = 16
    $0.layer.borderWidth = 0.7
    $0.layer.borderColor = UIColor.white.cgColor
    $0.clipsToBounds = true
    return $0
  }(UIImageView())
  
  private lazy var titleLabel: UILabel = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    return $0
  }(UILabel())
  
  // MARK: - Override Methods
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .systemGroupedBackground
    makeConstraint()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    makeConstraint()
  }
  
  // MARK: - Configure View
  
  func configureView(using attachmentItem: AttachmentItem) {
    self.titleLabel.text = attachmentItem.fileName
    self.imageDetailView.image = attachmentItem.thumbImage
  }
  
  private func makeConstraint() {
    contentView.addSubview(containerView)
    containerView.addSubview(imageDetailView)
    containerView.addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
      containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      
      imageDetailView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
      imageDetailView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5),
      imageDetailView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
      imageDetailView.widthAnchor.constraint(equalToConstant: self.frame.width/3),
      imageDetailView.heightAnchor.constraint(equalToConstant: self.frame.width/3),
      
      titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
      titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
      titleLabel.leftAnchor.constraint(equalTo: imageDetailView.rightAnchor, constant: 15),
      titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5),
    ])
  }
}
