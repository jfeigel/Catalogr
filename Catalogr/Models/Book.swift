//
//  Book.swift
//  Catalogr
//
//  Created by jfeigel on 3/31/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation

/// Individual book saved in the Bookshelf
struct SavedBook: Codable, Equatable {
  var book: Book
  var bookID: String = ""
  var rating: Int = 0
  var read: Bool = false
  var borrowed: Bool = false
  var wishlist: Bool = false
  var modificationDate: Date?
  var creationDate: Date?
  
  static func == (lhs: SavedBook, rhs: SavedBook) -> Bool {
    return
      lhs.bookID == rhs.bookID &&
      lhs.rating == rhs.rating &&
      lhs.read == rhs.read &&
      lhs.borrowed == rhs.borrowed &&
      lhs.wishlist == rhs.wishlist &&
      lhs.modificationDate == rhs.modificationDate &&
      lhs.creationDate == rhs.creationDate
  }
}

/// Response from the Google Books API
struct BooksResponse: Codable {
  var kind: String
  var totalItems: Int
  var items: Array<Book>?
}

/// Error Response from the Google Books API
struct BooksErrorResponse: Codable {
  var error: ErrorResponse
}

struct ErrorResponse: Codable {
  var errors: Array<BooksError>?
  var code: Int
  var message: String
}

struct BooksError: Codable {
  var domain: String?
  var reason: String?
  var message: String?
  var extendedHelp: String?
}

/// Book object from the Google Books API
struct Book: Codable {
  var kind: String?
  var id: String
  var etag: String?
  var selfLink: String?
  var volumeInfo: VolumeInfo
  var saleInfo: SaleInfo?
  var accessInfo: AccessInfo?
  var searchInfo: SearchInfo?
  
  struct VolumeInfo: Codable {
    var title: String
    var subtitle: String?
    var authors: Array<String>?
    var publisher: String?
    var publishedDate: String?
    var description: String?
    var industryIdentifiers: Array<IndustryIdentifier>?
    var readingModes: ReadingModes?
    var pageCount: Int?
    var dimensions: Dimensions?
    var printType: String?
    var mainCategory: String?
    var categories: Array<String>?
    var maturityRating: String?
    var averageRating: Double?
    var ratingsCount: Int?
    var allowAnonLogging: Bool?
    var contentVersion: String?
    var panelizationSummary: PanelizationSummary?
    var imageLinks: ImageLinks?
    var language: String?
    var previewLink: String?
    var infoLink: String?
    var canonicalVolumeLink: String?

    struct IndustryIdentifier: Codable {
      var type: String
      var identifier: String
    }

    struct ReadingModes: Codable {
      var text: Bool
      var image: Bool
    }

    struct Dimensions: Codable {
      var height: String
      var width: String
      var thickness: String
    }

    struct PanelizationSummary: Codable {
      var containsEpubBubbles: Bool
      var containsImageBubbles: Bool
    }

    struct ImageLinks: Codable {
      var thumbnail: String?
      var small: String?
      var medium: String?
      var large: String?
      var extraLarge: String?
      var smallThumbnail: String?
    }
  }
  
  struct SaleInfo: Codable {
    var country: String?
    var saleability: String?
    var isEbook: Bool?
    var listPrice: ListPrice?
    var retailPrice: RetailPrice?
    var buyLink: String?

    struct ListPrice: Codable {
      var amount: Double
      var currencyCode: String
    }

    struct RetailPrice: Codable {
      var amount: Double
      var currencyCode: String
    }
  }
  
  struct AccessInfo: Codable {
    var country: String?
    var viewability: String?
    var embeddable: Bool?
    var publicDomain: Bool?
    var textToSpeechPermission: String?
    var epub: Epub?
    var pdf: Pdf?
    var webReaderLink: String?
    var accessViewStatus: String?
    var quoteSharingAllowed: Bool?
    var downloadAccess: DownloadAccess?
    
    struct Epub: Codable {
      var isAvailable: Bool
    }
    
    struct Pdf: Codable {
      var isAvailable: Bool
    }

    struct DownloadAccess: Codable {
      var kind: String?
      var volumeId: String?
      var restricted: Bool?
      var deviceAllowed: Bool?
      var justAcquired: Bool?
      var maxDownloadDevices: Int?
      var downloadsAcquired: Int?
      var nonce: String?
      var source: String?
      var reasonCode: String?
      var message: String?
      var signature: String?
    }
  }
  
  struct SearchInfo: Codable {
    var textSnippet: String
  }
}
