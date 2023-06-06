//
//  FileManager+Extension.swift
//  Files
//
//  Created by MAHESHWARAN on 04/06/23.
//

import Foundation
import UIKit

extension FileManager {
  
  // MARK: - Create Folder
  
  var documentDirectory: URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  }
  
  func makePath(using path: String) -> URL {
    return documentDirectory.appendingPathComponent(path)
  }
  
  func isDirectoryExist(at url: URL) -> Bool {
    var isDir: ObjCBool = false
    _ = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
    return isDir.boolValue
  }
  
  func createDirectory(name: String) -> URL? {
    let url = makePath(using: name)
    do {
      try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    } catch {
      print("Error While create directory")
    }
    return url
  }
  
  // MARK: - Write
  
  func writeData(_ data: Data?, filePath: URL?) {
    guard let data, let filePath else {
      print("Invalid url or filePath")
      return
    }
    do {
      try data.write(to: filePath)
    } catch {
      print("Failed to save file in File Manager")
    }
  }
  
  // MARK: - Delete Files
  
  func deleteFile(at url: URL) {
    guard self.fileExists(atPath: url.path) else { return }
    do {
      try FileManager.default.removeItem(at: url)
    } catch {
      print("Error while deleting for URL: \(url)")
    }
  }
  
  func deleteFolder(at url: URL) {
    guard self.fileExists(atPath: url.path) else { return }
    do {
      try FileManager.default.removeItem(at: url.deletingLastPathComponent())
    } catch {
      print("Error while deleting for URL: \(url)")
    }
  }
}
