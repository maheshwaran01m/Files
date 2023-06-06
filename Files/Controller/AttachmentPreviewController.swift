//
//  AttachmentPreviewController.swift
//  Files
//
//  Created by MAHESHWARAN on 06/06/23.
//

import Foundation
import QuickLook

class AttachmentPreviewController: QLPreviewController {
  
  var attachmentItems: [(URL, String)] = []
  
  init(attachmentItems: [AttachmentItem]) {
    super.init(nibName: nil, bundle: nil)
    self.attachmentItems = attachmentItems.map({ attachment -> (URL, String) in
      guard let localPath = attachment.localPath, let fileName = attachment.fileName else {
        return (URL(fileURLWithPath: ""), "")
      }
      return (URL(fileURLWithPath: localPath), fileName)
    })
    self.dataSource = self
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}

// MARK: - QLPreviewControllerDataSource

extension AttachmentPreviewController: QLPreviewControllerDataSource {
  
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    return attachmentItems.count
  }
  
  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    guard let preview = controller as? AttachmentPreviewController else {
      return CustomPreviewItems(url: URL(string: ""), title: "") as QLPreviewItem
    }
    let item = preview.attachmentItems[index]
    let previewItem = CustomPreviewItems(url: item.0, title: item.1)
    return previewItem as QLPreviewItem
  }
}

class CustomPreviewItems: NSObject, QLPreviewItem {
  
  var previewItemURL: URL?
  var previewItemTitle: String?
  
  init(url: URL?, title: String?) {
    previewItemURL = url
    previewItemTitle = title
  }
}
