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
    $0.estimatedRowHeight = UITableView.automaticDimension
    $0.tableFooterView = UIView()
    $0.sectionHeaderTopPadding = 0.0
    return $0
  }(UITableView(frame: .zero, style: .insetGrouped))
  
  lazy var addButton: UIBarButtonItem = {
    return UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain,
                           target: self, action: #selector(createNewAttachment))
  }()
  
  private var attachmentManager: AttachmentManager?
  
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
    self.view.addSubview(tableView)
    tableView.backgroundColor = .systemBackground
    tableView.dataSource = self
    tableView.delegate = self
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
    return 5
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentDetailCell", for: indexPath) as? AttachmentDetailCell else {
      return UITableViewCell()
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
  
  func tableView(_ tableView: UITableView,
                 trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = UIContextualAction(style: .destructive, title: nil) { _, _, complete in
          self.tableView.deleteRows(at: [indexPath], with: .automatic)
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
    attachmentManager = AttachmentManager(delegate: self)
    attachmentManager?.delegate = self
    attachmentManager?.openActionSheet(in: self)
  }
  
  func attachmentManager(_ attachmentItem: AttachmentItem) {
    print(attachmentItem)
  }
}
