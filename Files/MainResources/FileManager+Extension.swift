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
  
  func makePath(using path: String) -> URL? {
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    return url?.appendingPathComponent(path)
  }
  
  func isDirectoryExist(at url: URL) -> Bool {
    var isDir: ObjCBool = false
    _ = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
    return isDir.boolValue
  }
  
  func createDirectory(name: String) -> URL? {
    guard let url = makePath(using: name) else { return nil }
    do {
      try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    } catch {
      print("Error While create directory")
    }
    return url
  }
  
  // MARK: - Read
  
  func isFileExist(at url: URL) -> Bool {
    return fileExists(atPath: url.path)
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
    guard self.isFileExist(at: url) else { return }
    do {
      try FileManager.default.removeItem(at: url)
    } catch {
      print("Error while deleting for URL: \(url)")
    }
  }
  
  func deleteFolder(at url: URL) {
    guard self.isFileExist(at: url) else { return }
    do {
      try FileManager.default.removeItem(at: url.deletingLastPathComponent())
    } catch {
      print("Error while deleting for URL: \(url)")
    }
  }
}
