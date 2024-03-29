//
//  ViewController.swift
//  Files
//
//  Created by MAHESHWARAN on 04/06/23.
//

import UIKit

class ViewController: UIViewController {
  
  // MARK: - Outlets
  
  lazy var tableView: UITableView = {
    $0.tableFooterView = UIView()
    $0.backgroundColor = .systemGroupedBackground
    $0.sectionHeaderTopPadding = 0.0
    $0.estimatedRowHeight = UITableView.automaticDimension
    return $0
  }(UITableView(frame: .zero, style: .insetGrouped))
  
  lazy var addButton: UIBarButtonItem = {
    return UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain,
                           target: self, action: #selector(createNewAttachment))
  }()
  
  private var attachmentManager: AttachmentManager?
  private var viewModel = AttachmentListViewModel()
  
  // MARK: - Override Method
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
  }
  
  private func configureView() {
    self.title = "Files"
    self.view.backgroundColor = .systemBackground
    configureTableView()
    configureNavigationBarButton()
  }
  
  private func configureNavigationBarButton() {
    self.navigationItem.rightBarButtonItem = addButton
  }
  
  // MARK: - TableView
  
  private func configureTableView() {
    view.addSubview(tableView)
    tableView.backgroundColor = .systemBackground
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = 80
    tableView.register(AttachmentDetailCell.self,
                       forCellReuseIdentifier: AttachmentDetailCell.reuseIdentifier)
    tableViewConstraint()
  }
  
  private func tableViewConstraint() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}

// MARK: - TableView DataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.attachmentItem.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentDetailCell",
                                                   for: indexPath) as? AttachmentDetailCell else {
      return UITableViewCell()
    }
    cell.configureView(using: viewModel.attachmentItem[indexPath.row])
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    guard self.presentedViewController == nil,
          let index = viewModel.attachmentItem.firstIndex(where: {
            $0.privateID == viewModel.attachmentItem[indexPath.row].privateID
          }) else { return }
    let previewController = AttachmentPreviewController(attachmentItems: viewModel.attachmentItem)
    DispatchQueue.main.async {
      self.present(previewController, animated: true)
      previewController.currentPreviewItemIndex = index
    }
  }
  
  func tableView(_ tableView: UITableView,
                 trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = UIContextualAction(style: .destructive, title: nil) { _, _, complete in
      let privatID = self.viewModel.attachmentItem[indexPath.row].privateID ?? ""
      self.viewModel.deleteAttachmentItem(privatID) {
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
      }
      complete(true)
    }
    delete.image = UIImage(systemName: "trash")
    
    let deleteAction = UISwipeActionsConfiguration(actions: [delete])
    deleteAction.performsFirstActionWithFullSwipe = true
    return deleteAction
  }
}

// MARK: - Custom Methods

extension ViewController: AttachmentDelegate {
  
  @objc private func createNewAttachment(_ sender: UIBarButtonItem) {
    attachmentManager = AttachmentManager(directoryPath: viewModel.directoryPath, delegate: self)
    attachmentManager?.delegate = self
    attachmentManager?.openActionSheet(in: self, sender: sender)
  }
  
  func attachmentManager(_ attachmentItem: AttachmentItem, type: AttachmentType) {
    if type == .image {
      let vc = QuickLookEditorVC(for: attachmentItem)
      vc.saveDelegate = self
      let navigationVC = UINavigationController(rootViewController: vc)
      navigationVC.modalPresentationStyle = .fullScreen
      present(navigationVC, animated: true)
    } else {
      getCustomFileName { [weak self] fileName in
        self?.addAttachmentItem(attachmentItem, for: fileName)
      }
    }
  }
  
  func addAttachmentItem(_ attachmentItem: AttachmentItem, for fileName: String? = nil) {
    var finalAttachmentItem: AttachmentItem
    
    if let fileName, let newAttachmentItem = attachmentItem.move(fileName) {
      finalAttachmentItem = newAttachmentItem
    } else {
      finalAttachmentItem = attachmentItem
    }
    viewModel.createAttachmentItem(finalAttachmentItem) { [weak self] in
      self?.tableView.reloadData()
    }
  }
}

extension ViewController: QuickLookEditorDelegate {
  
  func save(_ item: AttachmentItem) {
    getCustomFileName { [weak self] fileName in
      self?.addAttachmentItem(item, for: fileName)
    }
  }
}
