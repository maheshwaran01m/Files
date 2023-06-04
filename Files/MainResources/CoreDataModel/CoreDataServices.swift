//
//  CoreDataServices.swift
//  Files
//
//  Created by MAHESHWARAN on 04/06/23.
//

import Foundation
import CoreData

class CoreDataServices {
  
  static let shared = CoreDataServices()
  
  let container = NSPersistentContainer(name: "FilesDataModel")
  
  init() {
    container.loadPersistentStores { desc, error in
      if let error {
        print("Core Data failed to load: \(error.localizedDescription)")
        return
      }
      self.directoryPath()
      self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
  }
  
  private func directoryPath() {
    if let documentURL = FileManager.default.urls(for: .libraryDirectory,
                                                  in: .userDomainMask).last?.path {
      print("Path: \(documentURL)")
    }
  }
}

extension NSManagedObjectContext {
  
  static var main: NSManagedObjectContext {
    return CoreDataServices.shared.container.viewContext
  }
  
  // MARK: - Save
  
  /// Only performs a save if there are changes to commit.
  func saveContext() {
    do {
      if hasChanges {
        try save()
      }
    } catch let error {
      print("Failed to save: \(self.description). Reason: \(error.localizedDescription)")
    }
  }
}
