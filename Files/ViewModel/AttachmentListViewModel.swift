//
//  AttachmentListViewModel.swift
//  Files
//
//  Created by MAHESHWARAN on 04/06/23.
//

import Foundation
import CoreData
import UIKit

class AttachmentListViewModel: NSObject {
  
  var attachmentItem: [AttachmentItem] = []
  
  private var attachment: [Attachment]?
  
  private var fetchResultsController: NSFetchedResultsController<Attachment>?
  private var searchPredicate: NSPredicate?
  private var sortDescriptors: [NSSortDescriptor]?
  
  var moc: NSManagedObjectContext { return .main }
  
  private var predicate: NSPredicate? {
    var fetchPredicates: [NSPredicate] = []
    fetchPredicates.append(NSPredicate(format: "privateID != nil"))

    if let searchPredicate {
      fetchPredicates.append(searchPredicate)
    }
    return NSCompoundPredicate(andPredicateWithSubpredicates: fetchPredicates)
  }
  
  override init() {
    super.init()
    self.configureFRC()
  }
  
  func performFetch() {
    do {
      try fetchResultsController?.performFetch()
      fetchStudentsUsingFRC()
    } catch {
      print("Failed to Fetch students for Database")
    }
  }
  
  private func configureFRC() {
    let frc = makeFetchedResultsController(moc: moc)
    frc?.delegate = self
    self.fetchResultsController = frc as? NSFetchedResultsController<Attachment>
    performFetch()
  }
  
  func updateSearchResult(onCompletion: (() -> Void)?) {
    configureFRC()
    onCompletion?()
  }
  
  // MARK: - Save New Student
  
  func createAttachmentItem(_ attachmentItem: AttachmentItem, onCompletion: (() -> Void)?) {
    let newAttachmentItem = fetchObject(privateID: attachmentItem.privateID ?? "").first ?? Attachment(context: moc)
    newAttachmentItem.privateID = attachmentItem.privateID
    newAttachmentItem.fileName = attachmentItem.fileName
    newAttachmentItem.fileURL = attachmentItem.fileURL
    newAttachmentItem.fileExtension = attachmentItem.fileExtension
    moc.saveContext()
    onCompletion?()
  }
  
  func deleteAttachmentItem(_ privateID: String, onCompletion: (() -> Void)?) {
    moc.perform {
      guard let attachment = self.attachment?.first(where: { $0.privateID == privateID }) else {
        return
      }
      let fetchedStudent = self.moc.object(with: attachment.objectID)
      self.moc.delete(fetchedStudent)
      self.moc.saveContext()
      print("Deleted Attachment: \(attachment.fileName ?? "")")
      onCompletion?()
    }
  }
  
  // MARK: - Private Functions
  
  private func fetchStudentsUsingFRC() {
    guard let fetchAttachmentItem = fetchResultsController?.fetchedObjects, !fetchAttachmentItem.isEmpty else {
      attachmentItem = []
      return
    }
    attachment = fetchAttachmentItem
    attachmentItem = fetchAttachmentItem.compactMap({
      AttachmentItem(privateID: $0.privateID,
                     fileName: $0.fileName,
                     fileURL: $0.fileURL, fileExtension: $0.fileExtension,
                     thumbImage: UIImage(systemName: "star"))
    })
  }
  
  // MARK: - Fetch Assets
  
  func makeFetchedResultsController(moc: NSManagedObjectContext = .main) -> NSFetchedResultsController<NSFetchRequestResult>? {
    let sortDescriptors = [NSSortDescriptor(key: "fileName", ascending: true)]
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Attachment")
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors
    fetchRequest.includesPendingChanges = false
    fetchRequest.fetchBatchSize = 20
    return NSFetchedResultsController(fetchRequest: fetchRequest,
                                      managedObjectContext: moc,
                                      sectionNameKeyPath: nil,
                                      cacheName: nil)
  }
}
// MARK: - FRC Delegate

extension AttachmentListViewModel: NSFetchedResultsControllerDelegate {
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    fetchStudentsUsingFRC()
  }
}

// MARK: - FetchObjects

extension AttachmentListViewModel {
  
  func fetchObject(
    privateID: String,
    moc: NSManagedObjectContext = .main) -> [Attachment] {
      
      let fetchRequest = NSFetchRequest<Attachment>()
      fetchRequest.includesPendingChanges = false
      fetchRequest.fetchBatchSize = 20
      let entityDescription = NSEntityDescription.entity(forEntityName: "Attachment", in: moc)
      
      // Configure Fetch Request
      fetchRequest.entity = entityDescription
      fetchRequest.predicate = NSPredicate(format: "privateID = %@", privateID)
      
      fetchRequest.sortDescriptors = sortDescriptors
      do {
        return try moc.fetch(fetchRequest)
      } catch {
        return []
      }
    }
}
