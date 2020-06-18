//
//  CKSavedBook.swift
//  Catalogr
//
//  Created by jfeigel on 5/28/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation
import CloudKit

class CKSavedBook: CustomStringConvertible {
  static let recordType = "SavedBook"
  let recordID: CKRecord.ID
  
  let modificationDate: Date?
  let bookID: String
  let rating: Int
  let read: Bool
  let borrowed: Bool
  let wishlist: Bool
  
  var description: String {
    return "\n{\n"
      + "\tmodificationDate: \(self.modificationDate ?? Date.distantPast),\n"
      + "\tbookID: \(self.bookID),\n"
      + "\trating: \(self.rating),\n"
      + "\tread: \(self.read),\n"
      + "\tborrowed: \(self.borrowed),\n"
      + "\twishlist: \(self.wishlist)\n"
      + "}\n"
  }
  
  init?(record: CKRecord) {
    recordID = record.recordID
    
    modificationDate = record.modificationDate
    bookID = record["bookID"] as! String
    rating = record["rating"] as! Int
    read = record["read"] as? Bool ?? false
    borrowed = record["borrowed"] as? Bool ?? false
    wishlist = record["wishlist"] as? Bool ?? false
  }
}
