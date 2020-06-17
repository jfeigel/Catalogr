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
  
  private init() {
    container = CKContainer.default()
    publicDB = container.publicCloudDatabase
    privateDB = container.privateCloudDatabase
  }
  
  func addBook(_ newBook: SavedBook) {
    books.append(newBook)
    saveBookshelf(books)
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
      saveBookshelf(bookshelf)
    } catch {
      bookshelf = [SavedBook]()
      os_log("Failed to load Bookshelf", log: OSLog.default, type: .error)
    }

    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "SavedBook", predicate: predicate)

    privateDB.perform(query, inZoneWith: CKRecordZone.default().zoneID) { results, error in
      if let error = error {
        fatalError(error.localizedDescription)
      }

      guard let results = results else {
        self.books = bookshelf
        return completion(nil)
      }
      
      let ckBookshelf = results.compactMap {
        return CKSavedBook(record: $0)
      }
      
      self.mergeBookshelfs(local: bookshelf, cloud: ckBookshelf, completion: completion)
    }
  }
  
  private func mergeBookshelfs(local: [SavedBook], cloud: [CKSavedBook], completion: @escaping (String?) -> ()) {
    var updatedLocal = local
    let cloudIDs: [String] = cloud.map { $0.bookID }
    let localIDs: [String] = local.map { $0.bookID }
    
    let diff: [String] = cloudIDs.filter { localIDs.firstIndex(of: $0) == nil }
    
    if diff.count == 0 {
      books = local
      completion(nil)
    } else {
      let group = DispatchGroup()
      
      var error: String? = nil
      
      for bookID in diff {
        guard error == nil else { break }
        group.enter()
        GAPI.getBooks(searchText: bookID, type: .id) { (books, err) in
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
