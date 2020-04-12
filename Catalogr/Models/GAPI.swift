//
//  GAPI.swift
//  Catalogr
//
//  Created by jfeigel on 4/9/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation

final class GAPI {
  private static var key: String = "AIzaSyBbagy9yBWnF0oPjDsmU46rsCuGoK3h-Zk"
  private static var volumeQS: String = "https://www.googleapis.com/books/v1/volumes?q=%%type%%:%%query%%&key=\(key)&prettyPrint=false"
  
  static func getByIsbnURL(_ query: String) -> String {
    return self.getURL(type: "isbn", query: query)
  }
  
  static func getByTitleURL(_ query: String) -> String {
    return self.getURL(type: "intitle", query: query)
  }
  
  static func getByAuthorURL(_ query: String) -> String {
    return self.getURL(type: "inauthor", query: query)
  }
  
  private static func getURL(type: String, query: String) -> String {
    return self.volumeQS
    .replacingOccurrences(of: #"%%type%%"#, with: type, options: .regularExpression)
    .replacingOccurrences(of: #"%%query%%"#, with: query, options: .regularExpression)
  }
}
