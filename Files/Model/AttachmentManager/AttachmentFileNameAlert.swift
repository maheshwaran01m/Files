//
//  AttachmentFileNameAlert.swift
//  Files
//
//  Created by MAHESHWARAN on 06/01/24.
//

import UIKit

extension UIViewController {
  
  func getCustomFileName(onCompletion: ((String?) -> Void)? = nil) {
    
    let alert = UIAlertController(title: "Add FileName",
                                  message: "Choose custom fileName",
                                  preferredStyle: .alert)
    alert.addTextField { textField in
      textField.placeholder = "Enter File Name"
      /*
      let imageView = UIImageView(image: UIImage(systemName: "square.and.pencil"))
      imageView.tintColor = .gray
      textField.rightView = imageView
      textField.rightViewMode = .whileEditing
       */
    }
    let saveButton = UIAlertAction(title: "Save",
                                   style: .default, handler: { [weak alert] _ in
      guard let name = alert?.textFields?[0].text, !name.isEmpty else {
        alert?.textFields?[0].resignFirstResponder()
        onCompletion?(nil)
        return
      }
      alert?.textFields?[0].resignFirstResponder()
      onCompletion?(name)
    })
    alert.addAction(UIAlertAction(title: "Skip", style: .cancel) { _ in
      onCompletion?(nil)
    })
    alert.addAction(saveButton)
    alert.preferredAction = saveButton
    
    self.modalPresentationStyle = .fullScreen
    if let popOver = alert.popoverPresentationController {
      popOver.sourceView = self.view
    }
    present(alert, animated: true, completion: nil)
  }
}
