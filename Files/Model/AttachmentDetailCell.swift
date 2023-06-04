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
  
  // MARK: - Override Methods
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .systemBackground
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure View
  
  func configureView(using attachmentItem: AttachmentItem) {
    self.textLabel?.text = attachmentItem.fileName
    self.detailTextLabel?.text = attachmentItem.privateID
    self.detailTextLabel?.textColor = .gray
  }
}
