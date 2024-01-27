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
  var directoryPath: String
  
  init(privateID: String? = nil,
       fileName: String? = nil,
       fileURL: URL? = nil,
       fileExtension: String? = nil,
       directoryPath: String,
       thumbImage: UIImage? = nil) {
    self.privateID = privateID
    self.fileName = fileName
    self.fileURL = fileURL
    self.fileExtension = fileExtension
    self.directoryPath = directoryPath
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
    guard let privateID, let fileName else { return nil }
    let finalPath = "/\(directoryPath)/attachments/" + privateID + "/" + fileName
    return finalPath
  }
  
  var isSavedLocally: Bool {
    guard let localPath else { return false }
    return FileManager.default.fileExists(atPath: localPath)
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
  
  // MARK: - Move
  
  func move(_ fileName: String) -> Self? {
    if let localPath {
      let url = URL(fileURLWithPath: localPath)
      let extn = url.pathExtension
      let oldURL = url.deletingLastPathComponent().path + "/"
      let fileName = fileName + "." + extn
      let newFilePath = oldURL + fileName
      
      do {
        try FileManager.default.moveItem(atPath: url.path, toPath: newFilePath)
        
        if FileManager.default.fileExists(atPath: newFilePath) {
          let attachment = self
          attachment.fileName = fileName
          attachment.fileURL = URL(fileURLWithPath: newFilePath)
          return attachment
        }
      } catch {
        print("""
              Failed to move for URL: \(url),
              Reason: \(error.localizedDescription)
              """)
        return nil
      }
    }
    return nil
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
