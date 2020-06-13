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
  
  var books: [SavedBook]! {
    didSet {
      saveBookshelf(books)
    }
  }
  
  init() {
    container = CKContainer.default()
    publicDB = container.publicCloudDatabase
    privateDB = container.privateCloudDatabase
    books = loadBookshelf()
  }
  
  func addBook(_ newBook: SavedBook) {
    books.append(newBook)
    saveBookshelf(books)
  }
  
  private func loadBookshelf() -> [SavedBook]  {
    var bookshelf: [SavedBook]
//    var ckBookshelf = [CKSavedBook]()
    let decoder = JSONDecoder()
    
    do {
      let data = try Data(contentsOf: Bookshelf.ArchiveURL)
      bookshelf = try decoder.decode([SavedBook].self, from: data)
      for i in bookshelf.indices {
        bookshelf[i].bookID = bookshelf[i].book.id
      }
      saveBookshelf(bookshelf)
    } catch {
      bookshelf = [SavedBook]()
      os_log("Failed to load Bookshelf", log: OSLog.default, type: .error)
    }

//    let predicate = NSPredicate(value: true)
//    let query = CKQuery(recordType: "SavedBook", predicate: predicate)
//
//    privateDB.perform(query, inZoneWith: CKRecordZone.default().zoneID) { results, error in
//      if let error = error {
//        os_log("%s", type: .error, error as CVarArg)
//      }
//
//      guard let results = results else { return }
//      ckBookshelf = results.compactMap {
//        CKSavedBook(record: $0)
//      }
//    }
    
    return bookshelf
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
