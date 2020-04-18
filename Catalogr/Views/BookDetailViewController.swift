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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let bookData = book.book
    
    if let imageLinks = bookData.volumeInfo.imageLinks, let thumbnail = imageLinks.thumbnail {
      bookImage.load(url: URL(string: thumbnail)!, completion: nil)
    } else {
      bookImage.image = UIImage(named: "no_cover_thumb")
    }
    bookImage.dropShadow(type: "oval")
    bookTitle.text = bookData.volumeInfo.title
    bookSubtitle.text = bookData.volumeInfo.subtitle
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    backgroundView.roundCorners(corners: [.topLeft, .topRight, .bottomRight, .bottomLeft], radius: 44)
  }
  
}
