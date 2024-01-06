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
    contentView.addSubview(imageDetailView)
    contentView.addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      imageDetailView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
      imageDetailView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
      imageDetailView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
      imageDetailView.widthAnchor.constraint(equalToConstant: 80),
      
      titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
      titleLabel.centerYAnchor.constraint(equalTo: imageDetailView.centerYAnchor),
      titleLabel.leftAnchor.constraint(equalTo: imageDetailView.rightAnchor, constant: 15),
      titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
    ])
  }
}
