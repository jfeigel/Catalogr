//
//  BooksResponse.swift
//  Catalogr
//
//  Created by jfeigel on 3/31/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation

struct BooksResponse: Codable {
  var kind: String
  var totalItems: Int
  var items: Array<Book>?
}
