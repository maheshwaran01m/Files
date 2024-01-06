//
//  AttachmentManager.swift
//  Files
//
//  Created by MAHESHWARAN on 04/06/23.
//

import Foundation
import UIKit
import AVFoundation
import MobileCoreServices
import PhotosUI

protocol AttachmentDelegate: AnyObject {
  func attachmentManager(_ attachmentItem: AttachmentItem, type: AttachmentType)
}

enum AttachmentType {
  case image, file
}

class AttachmentManager: NSObject {
  
  weak var delegate: AttachmentDelegate?
  
  private var presentingVC: UIViewController?
  
  private let directoryPath: String
  
  // MARK: - Initializer
  
  init(directoryPath: String = "Files", delegate: AttachmentDelegate? = nil) {
    self.directoryPath = directoryPath
    self.delegate = delegate
  }
  
  // MARK: - Attachment Options
  
  func openActionSheet(in vc: UIViewController, sender: UIBarButtonItem? = nil) {
    
    let actionSheet = UIAlertController(
      title: "Choose an attachment source", message: nil, preferredStyle: .actionSheet)
    
    let librayOption = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
      self?.presentPhotoPicker()
    }
    
    let documentOption = UIAlertAction(title: "Documents", style: .default) { [weak self] _ in
      self?.presentDocumentPicker()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    let actions = [librayOption, documentOption, cancelAction]
    actions.forEach({ actionSheet.addAction($0) })
    vc.modalPresentationStyle = .fullScreen
    if let popOver = actionSheet.popoverPresentationController {
      vc.modalPresentationStyle = .popover
      popOver.sourceView = vc.view
      popOver.barButtonItem = sender
      popOver.sourceRect = CGRect(x: vc.view.bounds.midX,
                                  y: vc.view.bounds.midY,
                                  width: 0, height: 0)
    }
    vc.present(actionSheet, animated: true)
    presentingVC = vc
  }
  
  private func presentPhotoPicker() {
    /* ImagePicker
     let imagePicker = UIImagePickerController()
     imagePicker.delegate = self
     imagePicker.sourceType = .photoLibrary
     presentingVC?.present(imagePicker, animated: true)
     */
    let picker = PHPickerViewController(configuration: PHPickerConfiguration())
    picker.delegate = self
    presentingVC?.present(picker, animated: true)
  }
  private func presentDocumentPicker() {
    let type: [UTType] = [.pdf, .png, .jpeg, .video, .movie, .text,
                          .mpeg4Movie, .mp3, .rtf, .init(filenameExtension: "doc") ?? .pdf]
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: type)
    documentPicker.delegate = self
    documentPicker.allowsMultipleSelection = false
    presentingVC?.present(documentPicker, animated: true)
  }
}

extension AttachmentManager: PHPickerViewControllerDelegate {
  
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    guard let result = results.first else { return }
    
    let provider = result.itemProvider
    
    if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
      provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
        guard error == nil else { return }
        DispatchQueue.main.async {
          self?.handleAttachedFile(at: url)
        }
      }
    } else if provider.canLoadObject(ofClass: UIImage.self) {
      provider.loadObject(ofClass: UIImage.self) { [weak self] photo, error in
        guard error == nil else { return }
        DispatchQueue.main.async {
          let image = photo as? UIImage
          self?.handleAttachedImage(image)
        }
      }
    } else if provider.canLoadObject(ofClass: PHLivePhoto.self) {
      // Live Photo
    }
  }
}

extension AttachmentManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    presentingVC?.dismiss(animated: true)
    if let videoURL = info[.mediaURL] as? URL {
      self.handleAttachedFile(at: videoURL)
    } else if let image = info[.originalImage] as? UIImage {
      self.handleAttachedImage(image)
    }
  }
  
  private func handleAttachedImage(_ image: UIImage?, imageName: String? = nil) {
    presentingVC?.dismiss(animated: true)
    
    guard let image, let attachmentItem = saveImage(image) else { return }
    delegate?.attachmentManager(attachmentItem,  type: .image)
  }
}

extension AttachmentManager: UIDocumentPickerDelegate {
  
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    presentingVC?.dismiss(animated: true)
    handleAttachedFile(at: urls.first)
  }
  
  private func handleAttachedFile(at fileUrl: URL?, fileName: String? = nil) {
    guard let fileUrl, let attachmentItem = saveFile(fileURL: fileUrl) else { return }
    delegate?.attachmentManager(attachmentItem,  type: .file)
  }
  
  private func saveImage(
    _ image: UIImage, fileName name: String? = nil,
    privateID: String = UUID().uuidString) -> AttachmentItem? {
      
      let parentFolder = "\(directoryPath)/attachments/\(privateID)"
      guard let folderPath = FileManager.default.createDirectory(name: parentFolder) else {
        return nil
      }
      let fileName = (name ?? "image") + ".jpeg"
      let finalPath = folderPath.appendingPathComponent(fileName)
      let imageData = image.jpegData(compressionQuality: 0.8)
      
      FileManager.default.writeData(imageData, filePath: finalPath)
      
      return .init(privateID: privateID, fileName: fileName, fileURL: finalPath,
                   fileExtension: "jpg", directoryPath: directoryPath)
    }
  
  private func saveFile(
    fileURL url: URL, fileName name: String? = nil,
    privateID: String = UUID().uuidString) -> AttachmentItem? {
      
      let parentFolder = "\(directoryPath)/attachments/\(privateID)"
      guard let folderPath = FileManager.default.createDirectory(name: parentFolder) else {
        return nil
      }
      let fileName = name ?? url.deletingPathExtension().lastPathComponent
      let extn = url.pathExtension.lowercased()
      let fileNameWithExtension = fileName + "." + extn
      
      let finalPath = folderPath.appendingPathComponent(fileNameWithExtension)
      
      do {
        let fileData = try Data(contentsOf: url)
        FileManager.default.writeData(fileData, filePath: finalPath)
      } catch {
        print("Failed to convert data from URL")
      }
      
      return .init(privateID: privateID, fileName: fileNameWithExtension,fileURL: finalPath,
                   fileExtension: url.pathExtension, directoryPath: directoryPath)
    }
  
  func generateAttachmentItem(for url: URL) -> AttachmentItem? {
    let privateID = url.deletingPathExtension().deletingLastPathComponent().lastPathComponent
    let fileName = url.deletingPathExtension().lastPathComponent
    let extn = url.pathExtension.lowercased()
    
    return .init(
      privateID: privateID,
      fileName: fileName + ".\(extn)",
      fileURL: url,
      fileExtension: extn,
      directoryPath: directoryPath)
  }
}
