//
//  AddBookViewController.swift
//  Catalogr
//
//  Created by jfeigel on 3/31/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class AddBookViewController: UIViewController {
  var book: Book!
  var selectedIndex: Int!
  
  @IBOutlet var backgroundView: UIView!
  @IBOutlet var bookImage: UIImageView!
  @IBOutlet var bookTitle: UILabel!
  @IBOutlet var bookSubtitle: UILabel!
  @IBOutlet var imageActivityIndicator: UIActivityIndicatorView!

  @IBAction func addBook(_ sender: UIButton) {
    self.performSegue(withIdentifier: "addBookUnwind", sender: nil)
  }
  
  @IBAction func dismiss(_ sender: UIButton) {
    let segueIdentifier = selectedIndex == 0 ? "cancelAddBookUnwindToBookshelf" : "cancelAddBookUnwind"
    self.performSegue(withIdentifier: segueIdentifier, sender: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    backgroundView.layer.cornerRadius = 20
    
    if let book = book {
      if let imageLinks = book.volumeInfo.imageLinks, let thumbnail = imageLinks.thumbnail {
        imageActivityIndicator.startAnimating()
        bookImage.load(url: URL(string: thumbnail)!) { (image) in
          self.imageActivityIndicator.stopAnimating()
        }
      } else {
        bookImage.image = UIImage(named: "no_cover_thumb")
      }
      bookImage.dropShadow(type: .oval)
      bookTitle.text = book.volumeInfo.title
      bookSubtitle.text = book.volumeInfo.subtitle
    }
  }
  
}
