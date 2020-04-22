//
//  BookDetailViewController.swift
//  Catalogr
//
//  Created by jfeigel on 4/17/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {
  
  var book: SavedBook!
  
  @IBOutlet var backgroundView: UIView!
  @IBOutlet weak var bookImage: UIImageView!
  @IBOutlet weak var bookTitle: UILabel!
  @IBOutlet weak var bookSubtitle: UILabel!
  @IBOutlet var objectViewer: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let bookData = book.book
    
    if let imageLinks = bookData.volumeInfo.imageLinks, let thumbnail = imageLinks.thumbnail {
      bookImage.load(url: URL(string: thumbnail)!) { _ in
        self.bookImage.dropShadow(type: .oval)
      }
    } else {
      bookImage.image = UIImage(named: "no_cover_thumb")
      bookImage.dropShadow(type: .oval)
    }
    bookTitle.text = bookData.volumeInfo.title
    bookSubtitle.text = bookData.volumeInfo.subtitle
    
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let jsonData = try encoder.encode(book)
      objectViewer.text = (String(data: jsonData, encoding: .utf8) ?? "{}")
    } catch {
      print("JSON Serialization error: \(error)")
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    backgroundView.roundCorners(corners: [.topLeft, .topRight, .bottomRight, .bottomLeft], radius: nil)
  }
  
}
