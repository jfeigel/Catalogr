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

  @IBOutlet weak var bookImage: UIImageView!
  @IBOutlet var bookTitle: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let book = book {
      bookImage.load(url: URL(string: book.volumeInfo.imageLinks!.thumbnail)!)
      bookTitle.text = book.volumeInfo.title
    }
  }
}
