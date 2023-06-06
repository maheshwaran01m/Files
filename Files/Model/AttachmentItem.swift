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
    self.thumbImage = getPlaceholderImage ?? UIImage(systemName: "photo")
  }
}

extension AttachmentItem {
  
  var localPath: String? {
    let document = FileManager.default.documentDirectory.path
    guard let filePath else { return document }
    let finalPath = document + filePath
    guard FileManager.default.fileExists(atPath: finalPath) else { return document }
    
    return finalPath
  }
  
  var filePath: String? {
    guard let privateID, let fileName, let fileExtension else { return nil }
    let finalPath = "/attachments/" + privateID + "/" + fileName + "." + fileExtension
    return finalPath
  }
  
  var getPlaceholderImage: UIImage? {
    let placeHolderImage = { () -> UIImage? in
      return UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
    }
    guard let localPath, let fileExtension else { return placeHolderImage() }
    var image: UIImage?
    
    switch fileExtension.lowercased() {
    case "jpg", "png", "jpeg", "svg":
      image = UIImage(contentsOfFile: localPath)
    case "mp4", "mov", "mkv", "mpeg-4":
      image = UIImage(systemName: "video.circle")
    case "mp3", "m4a":
      image = UIImage(systemName: "music.mic.circle")
    case "pdf", "txt", "rtf", "doc", "xls":
      image = UIImage(systemName: "doc.circle")
    default:
      image = UIImage(systemName: "photo")
    }
    return image
  }
  
  // MARK: - Delete Folder
  
  func deleteFolder() {
    do {
      if let localPath, FileManager.default.fileExists(atPath: localPath) {
        try FileManager.default.removeItem(at: URL(fileURLWithPath: localPath).deletingLastPathComponent())
      }
    } catch {
      print("Failed to Delete the attachment")
    }
  }
}
