//
//  GAPI.swift
//  Catalogr
//
//  Created by jfeigel on 4/9/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation
import os.log

/// Google Books API SDK
class GAPI {
  static let shared = GAPI()
  
  /// Collection of URLQueryItems for all requests
  private var baseQueryItems: [URLQueryItem] = {
    let path = Bundle.main.path(forResource: "Keys", ofType: "plist")!
    let keys = NSDictionary(contentsOfFile: path)!
    let googleAPIKey = keys["googleAPIKey"] as! String
    
    return [
      URLQueryItem(name: "key", value: googleAPIKey),
      URLQueryItem(name: "printType", value: "books"),
      URLQueryItem(name: "prettyPrint", value: "false")
    ]
  }()
  
  /// Base URL for all requests
  private var urlComponents: URLComponents = {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "www.googleapis.com"
    urlComponents.path = "/books/v1/volumes"
    return urlComponents
  }()
  
  private let defaultSession = URLSession(configuration: .default)
  private var dataTasks: [URL: URLSessionDataTask] = [:]

  /**
   Construct a URL for a request to the Google Books API
   
   - Parameters:
      - type: The property by which to search
      - query: The text by which to search
      - startIndex: Index at which to start the results, in the case of paging. Defaults to `0`
   
   - Returns: An optional constructed URL
   */
  func getURL(type: QueryType, query: String, startIndex: Int = 0) -> URL? {
    return constructURL(type: type.rawValue, query: query, startIndex: startIndex, showPreorders: type != .isbn)
  }
  
  /**
   Actual construction of the URL
   
   - Parameters:
      - type: The property by which to search
      - query: The text by which to search
      - startIndex: Index at which to start the results, in the case of paging. Defaults to `0`
      - showPreorders: If the search results should include Preorders or not
   
   - Returns: An optional constructed URL
   */
  private func constructURL(type: String, query: String, startIndex: Int = 0, showPreorders: Bool = false) -> URL? {
    var tempUrlComponents = urlComponents
    tempUrlComponents.queryItems = baseQueryItems
    
    if type == "id" {
      tempUrlComponents.path = "\(tempUrlComponents.path)/\(query)"
    } else {
      tempUrlComponents.queryItems!.append(URLQueryItem(name: "q", value: "\(type):\(query)"))
      tempUrlComponents.queryItems!.append(URLQueryItem(name: "startIndex", value: String(startIndex)))
      tempUrlComponents.queryItems!.append(URLQueryItem(name: "showPreorders", value: String(showPreorders)))
    }
    
    return tempUrlComponents.url
  }
  
  /**
   Call the Google Books API to search for books
   
   - Parameters:
      - searchText: The text by which to search
      - type: The property by which to search
      - completion: Optional completion function
   */
  func getBooks(searchText: String, type: QueryType, completion: @escaping ([Book]?, String?) -> ()) {
    if let url = getURL(type: type, query: searchText) {
      var request = URLRequest(url: url)
      request.setValue(Bundle.main.bundleIdentifier!, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
      dataTasks[url] = defaultSession.dataTask(with: request) { [weak self] data, res, err in
        defer {
          self?.dataTasks[url] = nil
        }

        guard err == nil else {
          os_log("%s", type: .error, err! as CVarArg)
          DispatchQueue.main.async {
            completion(nil, err!.localizedDescription)
          }
          return
        }
        
        guard let resData = data else {
          os_log("Error: did not receive data", type: .error)
          DispatchQueue.main.async {
            completion(nil, "Error: did not receive data")
          }
          return
        }
        
        do {
          let error = try JSONDecoder().decode(BooksErrorResponse.self, from: resData), err = error.error
          if err.code > 300 || err.code < 200 {
            os_log("%s", type: .error, "ERROR: \(err.code) | \(err.message)" as CVarArg)
            DispatchQueue.main.async {
              completion(nil, "Error: An API error occurred. Please contact the developer.")
            }
          }
        } catch {}
        
        do {
          if type == .id {
            var book = try JSONDecoder().decode(Book.self, from: resData)
            if let thumbnail = book.volumeInfo.imageLinks?.thumbnail {
              book.volumeInfo.imageLinks!.thumbnail = thumbnail.replacingOccurrences(of: #"^http\:"#, with: "https:", options: .regularExpression)
            }
            
            completion([book], nil)
          } else {
            var books = try JSONDecoder().decode(BooksResponse.self, from: resData)
            if books.totalItems > 0 {
              for (index, book) in books.items!.enumerated() {
                if let thumbnail = book.volumeInfo.imageLinks?.thumbnail {
                  books.items![index].volumeInfo.imageLinks!.thumbnail = thumbnail.replacingOccurrences(of: #"^http\:"#, with: "https:", options: .regularExpression)
                }
              }
              DispatchQueue.main.async {
                completion(books.items!, nil)
              }
            } else {
              os_log("Error: No books found", type: .error)
              DispatchQueue.main.async {
                completion(nil, "Error: No books found")
              }
              return
            }
          }
        } catch DecodingError.keyNotFound(let codingKey, _) {
          os_log("Error: Cannot convert data to JSON", type: .error)
          os_log("No key found for: %s", type: .error, codingKey.stringValue as CVarArg)
          DispatchQueue.main.async {
            completion(nil, "Error: Cannot convert data to JSON")
          }
          return
        } catch {
          os_log("%s", type: .error, error as CVarArg)
          DispatchQueue.main.async {
            completion(nil, "Error: Unknown error occurred")
          }
          return
        }
      }
      
      dataTasks[url]?.resume()
    }
  }
}

/// Valid types by which to query the Google Books API
enum QueryType: String {
  case id
  case isbn
  case title = "intitle"
  case author = "inauthor"
}
