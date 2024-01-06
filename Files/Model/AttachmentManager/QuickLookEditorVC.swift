//
//  QuickLookEditorVC.swift
//  Files
//
//  Created by MAHESHWARAN on 05/01/24.
//

import UIKit
import QuickLook

protocol QuickLookEditorDelegate: AnyObject {
  func save(_ item: AttachmentItem)
}

class QuickLookEditorVC: UIViewController {
  
  private let item: AttachmentItem?
  private var localURL: URL?
  private var preview: QLPreviewController?
  private var alertController: UIAlertController?
  private var isFromDiscard = false
  
  weak var saveDelegate: QuickLookEditorDelegate?
  
  init(for item: AttachmentItem?) {
    self.item = item
    super.init(nibName: nil, bundle: nil)
    localURL = createCopyOfFile(item?.fileURL)
  }
  
  required init?(coder: NSCoder) {
    item = nil
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupQuickLook()
  }
  
  private func setupQuickLook() {
    guard preview == nil else { return }
    let preview = QLPreviewController()
    preview.delegate = self
    preview.dataSource = self
    preview.currentPreviewItemIndex = 0
    self.preview = preview
    setupNavigationBarItems()
    
    navigationController?.present(preview, animated: true)
  }
  
  private func setupNavigationBarItems() {
    let cancelButton = UIBarButtonItem(
      image: UIImage(systemName: "chevron.backward"),
      style: .plain, target: self,
      action: #selector(showDiscardAlert))
    
    preview?.navigationItem.leftBarButtonItem = cancelButton
  }
}

// MARK: - QLPreviewControllerDataSource

extension QuickLookEditorVC: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
  
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    return 1
  }
  
  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    PreviewItem(url: localURL, title: localURL?.lastPathComponent ?? "")
  }
  
  // MARK: - QLPreviewControllerDelegate
  
  func previewController(_ controller: QLPreviewController,
                         editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
    .updateContents
  }
  
  
  func previewControllerWillDismiss(_ controller: QLPreviewController) {
    addAttachmentItem()
  }
}

extension QuickLookEditorVC {
  
  // MARK: - NavigationItem
  
  @objc private func showDiscardAlert() {
    showPopupForDiscardAlert()
  }
  
  @objc private func showSaveAlert() {
    addAttachmentItem()
  }
  
  private func clearButtonClicked() {
    localURL = createCopyOfFile(item?.fileURL)
    preview?.reloadData()
  }
  
  private func addAttachmentItem() {
    guard !isFromDiscard else { return }
    deleteAttachmentFile()
    navigationController?.dismiss(animated: true) { [weak self] in
      guard let self else { return }
      if let item {
        saveDelegate?.save(item)
      }
    }
  }
  
  private func dismissVC() {
    self.navigationController?.dismiss(animated: true)
  }
  
  // MARK: - Discard Alert
  
  public func showPopupForDiscardAlert() {
    guard alertController == nil else { return }
    let message = "Attachment File will be discarded. Do you wish to proceed?"
    
    let alert = UIAlertController(
      title: "Warning",
      message: message,
      preferredStyle: .alert)
    
    // Back Button Action
    let proceedAction = UIAlertAction(title: "Proceed",
                                      style: .destructive) { [weak self] _ in
      self?.isFromDiscard = true
      self?.resetAlertController()
      self?.deleteAttachmentFolder()
    }
    
    let discardAction = UIAlertAction(title: "Discard Changes", style: .default) { [weak self] _ in
      self?.clearButtonClicked()
      self?.resetAlertController()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
      alert.dismiss(animated: true)
      self?.resetAlertController()
    }
    
    alert.addAction(proceedAction)
    alert.addAction(discardAction)
    alert.preferredAction = proceedAction
    alert.addAction(cancelAction)
    alertController = alert
    
    preview?.present(alert, animated: true)
  }
  
  private func resetAlertController() {
    alertController = nil
  }
}

extension QuickLookEditorVC {
  
  private func deleteAttachmentFolder() {
    do {
      if let url = item?.fileURL {
        try FileManager.default.removeItem(at: url.deletingLastPathComponent())
      }
    } catch {
      print("Error While deleting attachmentFile: ")
    }
    dismissVC()
  }
  
  private func deleteAttachmentFile(completion: (() -> Void)? = nil) {
    do {
      if let url = item?.fileURL, let oldURL = localURL {
        let newPath = oldURL.path.replacingOccurrences(of: "Copy", with: "")
        
        if FileManager.default.fileExists(atPath: url.path) {
          try FileManager.default.removeItem(at: url)
          // Replace original image with edited version of image
          try FileManager.default.moveItem(atPath: oldURL.path, toPath: newPath)
        }
        completion?()
      }
    } catch {
      print("Error While deleting attachmentFile: ")
      completion?()
    }
  }
  
  // MARK: - Create a Copy
  
  public func createCopyOfFile(_ url: URL?) -> URL? {
    guard let url, FileManager.default.fileExists(atPath: url.path),
          url.startAccessingSecurityScopedResource() else { return nil }
    do {
      let newPath = url.deletingPathExtension().path + "Copy.\(url.pathExtension)"
      // Clear the existing file before creating copy
      if FileManager.default.fileExists(atPath: newPath) {
        try FileManager.default.removeItem(atPath: newPath)
      }
      try FileManager.default.copyItem(atPath: url.path, toPath: newPath)
      return URL(fileURLWithPath: newPath)
      
    } catch {
      print("Error while creating copy of url: \(url.path)")
      return nil
    }
  }
}

extension QuickLookEditorVC {
  
  // MARK: - PreviewItem
  
  public class PreviewItem: NSObject, QLPreviewItem {
    public var previewItemURL: URL?
    public var previewItemTitle: String?
    
    public init(url: URL?, title: String?) {
      previewItemURL = url
      previewItemTitle = title
    }
  }
}
