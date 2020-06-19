//
//  Bookshelf.swift
//  Catalogr
//
//  Created by jfeigel on 4/28/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation
import CloudKit
import os.log

class Bookshelf {
  static let shared = Bookshelf()

  /// Archival Path for the Bookshelf
  static private let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.appendingPathComponent("bookshelf")
  
  let container: CKContainer
  let publicDB: CKDatabase
  let privateDB: CKDatabase
  lazy var operationQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.name = "Cloud Update Queue"
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
  
  private (set) var books: [SavedBook]! {
    didSet {
      books.sort { ($0.creationDate ?? Date.distantPast) < ($1.creationDate ?? Date.distantPast) }
      saveBookshelf(books)
    }
  }
  
  private var ckBooks: [CKSavedBook] = [CKSavedBook]()
  
  private init() {
    container = CKContainer.default()
    publicDB = container.publicCloudDatabase
    privateDB = container.privateCloudDatabase
  }
  
  func addBook(_ newBook: SavedBook) {
    books.append(newBook)
  }
  
  func removeBook(at: Int) {
    let removedBook = books.remove(at: at)
    
    guard let removedRecordIndex = ckBooks.firstIndex(where: { $0.bookID == removedBook.bookID }) else {
      os_log("%s", log: OSLog.default, type: .error, "Failed to find book with id \(removedBook.bookID) in ckBooks" as CVarArg)
      return
    }
    
    let removedRecord = ckBooks[removedRecordIndex]
    
    let deleteOperation = CKModifyRecordsOperation(recordIDsToDelete: [removedRecord.recordID])
    deleteOperation.database = privateDB
    
    operationQueue.addOperation(deleteOperation)
    
    deleteOperation.modifyRecordsCompletionBlock = { _, deletedRecords, err in
      if err != nil {
        fatalError(err!.localizedDescription)
      }
      
      self.ckBooks.remove(at: removedRecordIndex)
      print("Successfully deleted \(deletedRecords?.count ?? 0) record\((deletedRecords?.count ?? 0) != 1 ? "s" : "")")
    }
  }
  
  func loadBookshelf(completion: @escaping (String?) -> ()) {
    var bookshelf: [SavedBook]
    let decoder = JSONDecoder()
    
    do {
      let data = try Data(contentsOf: Bookshelf.ArchiveURL)
      bookshelf = try decoder.decode([SavedBook].self, from: data)
      for i in bookshelf.indices {
        bookshelf[i].bookID = bookshelf[i].book.id
      }
    } catch {
      bookshelf = [SavedBook]()
      os_log("Failed to load Bookshelf", log: OSLog.default, type: .error)
    }

    if FileManager.default.ubiquityIdentityToken != nil {
      let predicate = NSPredicate(value: true)
      let query = CKQuery(recordType: "SavedBook", predicate: predicate)
      query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

      privateDB.perform(query, inZoneWith: CKRecordZone.default().zoneID) { results, error in
        if let error = error {
          fatalError(error.localizedDescription)
        }

        guard let results = results, results.count > 0 else {
          self.books = bookshelf
          return completion(nil)
        }
        
        self.ckBooks = results.compactMap {
          return CKSavedBook(record: $0)
        }
        
        self.mergeBookshelfs(local: bookshelf, cloud: self.ckBooks, completion: completion)
      }
    } else {
      books = bookshelf
      completion(nil)
    }
  }
  
  private func mergeBookshelfs(local: [SavedBook], cloud: [CKSavedBook], completion: @escaping (String?) -> ()) {
    var updatedLocal = local
    var updatedCloud = [CKRecord]()
    let cloudIDs: [String] = cloud.map { $0.bookID }
    let localIDs: [String] = updatedLocal.map { $0.bookID }
    
    for i in updatedLocal.indices {
      var needsCloudUpdate = false
      var cloudBookRecord: CKSavedBook?
      let localBook = updatedLocal[i]
      if let cloudBookIndex = cloud.firstIndex(where: { $0.bookID == localBook.bookID }) {
        cloudBookRecord = cloud[cloudBookIndex]
        let localModDate = localBook.modificationDate ?? Date.distantPast
        let cloudModDate = cloudBookRecord!.modificationDate ?? Date.distantPast
        
        if localBook.creationDate == nil {
          updatedLocal[i].creationDate = cloudBookRecord!.creationDate
        }

        // If Cloud version of book record was modified later
        if localModDate < cloudModDate || cloudModDate == Date.distantPast {
          updatedLocal[i].creationDate = cloudBookRecord!.creationDate
          updatedLocal[i].modificationDate = cloudBookRecord!.modificationDate
          updatedLocal[i].rating = cloudBookRecord!.rating
          updatedLocal[i].read = cloudBookRecord!.read
          updatedLocal[i].borrowed = cloudBookRecord!.borrowed
          updatedLocal[i].wishlist = cloudBookRecord!.wishlist
        } else if localModDate > cloudModDate {
          needsCloudUpdate = true
        }
      } else {
        needsCloudUpdate = true
      }
      
      if needsCloudUpdate == true {
        let updatedCloudBook = CKRecord(recordType: CKSavedBook.recordType, recordID: cloudBookRecord?.recordID ?? CKRecord.ID())
        updatedCloudBook["bookID"] = localBook.bookID
        updatedCloudBook["rating"] = localBook.rating
        updatedCloudBook["read"] = localBook.read
        updatedCloudBook["borrowed"] = localBook.borrowed
        updatedCloudBook["wishlist"] = localBook.wishlist
        updatedCloud.append(updatedCloudBook)
        
        if cloudBookRecord == nil {
          let newCKSavedBook = CKSavedBook(record: updatedCloudBook)!
          ckBooks.append(newCKSavedBook)
        }
      }
    }
    
    let diff: [String] = cloudIDs.filter { localIDs.firstIndex(of: $0) == nil }
    
    if diff.count == 0 {
      books = updatedLocal
      completion(nil)
    } else {
      let group = DispatchGroup()
      
      var error: String? = nil
      
      for bookID in diff {
        guard error == nil else { break }
        group.enter()
        GAPI.shared.getBooks(searchText: bookID, type: .id) { (books, err) in
          guard err == nil else {
            error = err
            group.leave()
            return
          }
          guard let books = books, books.count > 0, let book = books.first else {
            group.leave()
            return
          }
          let cloudBook = cloud.first(where: { $0.bookID == bookID })
          let savedBook = SavedBook(book: book, bookID: book.id, rating: cloudBook!.rating, read: cloudBook!.read, borrowed: cloudBook!.borrowed, wishlist: cloudBook!.wishlist)
          
          updatedLocal.append(savedBook)
          group.leave()
        }
      }
      
      group.wait()
      books = updatedLocal
      completion(error)
    }
    
    if updatedCloud.count > 0 {
      let saveOperation = CKModifyRecordsOperation(recordsToSave: updatedCloud)
      saveOperation.database = privateDB
      
      operationQueue.addOperation(saveOperation)
      
      saveOperation.modifyRecordsCompletionBlock = { savedRecords, _, err in
        if err != nil {
          fatalError(err!.localizedDescription)
        }
        
        print("Successfully saved \(savedRecords?.count ?? 0) record\((savedRecords?.count ?? 0) != 1 ? "s" : "")")
      }
    }
  }
  
  private func saveBookshelf(_ updatedBooks: [SavedBook]) {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(updatedBooks)
      try data.write(to: Bookshelf.ArchiveURL)
    } catch {
      os_log("Failed to save Bookshelf", log: OSLog.default, type: .error)
    }
  }
}
