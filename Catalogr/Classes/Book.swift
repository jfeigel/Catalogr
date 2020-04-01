//
//  Book.swift
//  Catalogr
//
//  Created by jfeigel on 3/31/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

struct Book: Codable {
  var kind: String
  var id: String
  var etag: String
  var selfLink: String
  var volumeInfo: VolumeInfo
  var saleInfo: SaleInfo
  var accessInfo: AccessInfo
  var searchInfo: SearchInfo
}

struct VolumeInfo: Codable {
  var title: String
  var subtitle: String?
  var authors: Array<String>
  var publisher: String?
  var publishedDate: String
  var description: String?
  var industryIdentifiers: Array<IndustryIdentifier>
  var readingModes: ReadingModes
  var pageCount: Int
  var dimensions: Dimensions?
  var printType: String
  var mainCategory: String?
  var categories: Array<String>?
  var maturityRating: String?
  var averageRating: Double?
  var ratingsCount: Int?
  var allowAnonLogging: Bool?
  var contentVersion: String
  var panelizationSummary: PanelizationSummary
  var imageLinks: ImageLinks?
  var language: String
  var previewLink: String
  var infoLink: String
  var canonicalVolumeLink: String
}

struct SaleInfo: Codable {
  var country: String
  var saleability: String
  var isEbook: Bool
  var listPrice: ListPrice?
  var retailPrice: RetailPrice?
  var buyLink: String?
}

struct AccessInfo: Codable {
  var country: String
  var viewability: String
  var embeddable: Bool
  var publicDomain: Bool
  var textToSpeechPermission: String
  var epub: Epub
  var pdf: Pdf
  var webReaderLink: String
  var accessViewStatus: String
  var quoteSharingAllowed: Bool
  var downloadAccess: DownloadAccess?
}

struct SearchInfo: Codable {
  var textSnippet: String
}

struct Epub: Codable {
  var isAvailable: Bool
}

struct Pdf: Codable {
  var isAvailable: Bool
}

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
  var thumbnail: String
  var small: String?
  var medium: String?
  var large: String?
  var extraLarge: String?
  var smallThumbnail: String
}

struct ListPrice: Codable {
  var amount: Double
  var currencyCode: String
}

struct RetailPrice: Codable {
  var amount: Double
  var currencyCode: String
}

struct DownloadAccess: Codable {
  var kind: String
  var volumeId: String
  var restricted: Bool
  var deviceAllowed: Bool
  var justAcquired: Bool
  var maxDownloadDevices: Int
  var downloadsAcquired: Int
  var nonce: String
  var source: String
  var reasonCode: String
  var message: String
  var signature: String
}
