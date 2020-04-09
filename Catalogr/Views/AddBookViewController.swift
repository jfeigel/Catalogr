//
//  AddBookViewController.swift
//  Catalogr
//
//  Created by jfeigel on 3/31/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class AddBookViewController: UIViewController {
  var book: Book?
  
  @IBOutlet var backgroundView: UIView!
  @IBOutlet weak var bookImage: UIImageView!
  @IBOutlet var bookTitle: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    backgroundView.layer.cornerRadius = 10.0
    
    if let book = book {
      if let imageLinks = book.volumeInfo.imageLinks {
        bookImage.load(url: URL(string: imageLinks.thumbnail)!) { (image) in
          self.bookImage.frame.size = CGSize(width: image.size.width, height: image.size.height)
        }
      } else {
        bookImage.image = UIImage(named: "no_cover_thumb")
      }
      bookTitle.text = book.volumeInfo.title
    }
  }
}
