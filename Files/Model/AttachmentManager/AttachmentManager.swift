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
  
  // MARK: - Initializer
  
  init(delegate: AttachmentDelegate? = nil) {
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
          self?.handleAttachedFile(at: url, fileType: .movie)
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
      self.handleAttachedFile(at: videoURL, fileType: .video)
    } else if let image = info[.originalImage] as? UIImage {
      self.handleAttachedImage(image)
    }
  }
  
  private func handleAttachedImage(_ image: UIImage?, imageName: String? = nil) {
    presentingVC?.dismiss(animated: true)
    getCustomFileName { [weak self] fileName in
      if let attachmentItem = self?.saveImage(image, fileName: fileName) {
        self?.delegate?.attachmentManager(attachmentItem, type: .image)
      }
    }
  }
}

extension AttachmentManager: UIDocumentPickerDelegate {
  
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    presentingVC?.dismiss(animated: true)
    handleAttachedFile(at: urls.first, fileType: .png)
  }
  
  private func handleAttachedFile(at fileUrl: URL?, fileName: String? = nil,
                                  fileType: UTType) {
    guard let fileUrl else { return }
    getCustomFileName { [weak self] fileName in
      if let attachmentItem = self?.saveFile(fileURL: fileUrl, fileName: fileName) {
        self?.delegate?.attachmentManager(attachmentItem,  type: .file)
      }
    }
  }
  
  private func saveImage(
    _ image: UIImage?, fileName name: String? = nil,
    privateID: String = UUID().uuidString) -> AttachmentItem? {
      
      let parentFolder = "attachments/\(privateID)"
      guard let image, let folderPath = FileManager.default.createDirectory(name: parentFolder) else {
        return nil
      }
      let finalPath = folderPath.appendingPathComponent(name ?? "Image").appendingPathExtension("jpg")
      let imageData = image.jpegData(compressionQuality: 0.8)
      
      FileManager.default.writeData(imageData, filePath: finalPath)
      
      return AttachmentItem(privateID: privateID, fileName: name ?? "Image",
                            fileURL: finalPath,
                            fileExtension: "jpg")
    }
  
  private func saveFile(
    fileURL url: URL?, fileName name: String? = nil,
    privateID: String = UUID().uuidString) -> AttachmentItem? {
      
      let parentFolder = "attachments/\(privateID)"
      guard let url, let folderPath = FileManager.default.createDirectory(name: parentFolder) else {
        return nil
      }
      let fileNameEmpty = name?.isEmpty ?? false
      let fileName = !fileNameEmpty ? name : url.deletingPathExtension().lastPathComponent
      let fileNameWithExtension = (fileName ?? "") + "." + url.pathExtension
      
      let finalPath = folderPath.appendingPathComponent(fileNameWithExtension)
      
      let fileData = try? Data(contentsOf: url)
      FileManager.default.writeData(fileData, filePath: finalPath)
      
      return AttachmentItem(privateID: privateID, fileName: fileName,
                            fileURL: finalPath,
                            fileExtension: url.pathExtension)
    }
  
  private func getCustomFileName(onCompletion: ((String?) -> Void)? = nil) {
    
    let alert = UIAlertController(title: "Attachment Details",
                                  message: "",
                                  preferredStyle: .alert)
    alert.addTextField { textField in
      textField.placeholder = "File Name"
      let imageView = UIImageView(image: UIImage(systemName: "square.and.pencil"))
      imageView.tintColor = .gray
      textField.rightView = imageView
      textField.rightViewMode = .always
    }
    let doneButton = UIAlertAction(title: "Done",
                                   style: .default, handler: { [weak alert] _ in
      guard let name = alert?.textFields?[0].text, !name.isEmpty else {
        alert?.textFields?[0].resignFirstResponder()
        onCompletion?(nil)
        return
      }
      alert?.textFields?[0].resignFirstResponder()
      onCompletion?(name)
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(doneButton)
    presentingVC?.modalPresentationStyle = .fullScreen
    if let popOver = alert.popoverPresentationController {
      popOver.sourceView = presentingVC?.view
    }
    presentingVC?.present(alert, animated: true, completion: nil)
  }
}
