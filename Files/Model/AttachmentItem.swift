//
//  AttachmentItem.swift
//  Files
//
//  Created by MAHESHWARAN on 04/06/23.
//

import Foundation
import UIKit

class AttachmentItem {
  var privateID: String?
  var fileName: String?
  var fileURL: URL?
  var fileExtension: String?
  var thumbImage: UIImage?
  
  init(privateID: String? = nil,
       fileName: String? = nil,
       fileURL: URL? = nil,
       fileExtension: String? = nil,
       thumbImage: UIImage? = nil) {
    self.privateID = privateID
    self.fileName = fileName
    self.fileURL = fileURL
    self.fileExtension = fileExtension
    self.thumbImage = thumbImage
  }
}
