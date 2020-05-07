//
//  Bookshelf.swift
//  Catalogr
//
//  Created by jfeigel on 4/28/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation
import os.log

class Bookshelf {

  /// Archival Path for the Bookshelf
  static private let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.appendingPathComponent("bookshelf")
  
  var books: [SavedBook]! {
    get {
      return loadBookshelf()
    }
    set (updatedBooks) {
      saveBookshelf(updatedBooks)
    }
  }
  
  init() {
    books = loadBookshelf()
  }
  
  func addBook(_ newBook: SavedBook) {
    books.append(newBook)
    saveBookshelf(books)
  }
  
  private func loadBookshelf() -> [SavedBook]  {
    var bookshelf: [SavedBook]
    let decoder = JSONDecoder()
    
    do {
      let data = try Data(contentsOf: Bookshelf.ArchiveURL)
      bookshelf = try decoder.decode([SavedBook].self, from: data)
    } catch {
      bookshelf = [SavedBook]()
      os_log("Failed to load Bookshelf", log: OSLog.default, type: .error)
    }
    
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
