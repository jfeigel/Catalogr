//
//  SearchTableViewCell.swift
//  Catalogr
//
//  Created by jfeigel on 4/22/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
  
  var book: Book! {
    didSet {
      if let imageLinks = book.volumeInfo.imageLinks, let thumbnail = imageLinks.thumbnail {
        bookImage.load(url: URL(string: thumbnail)!, completion: nil)
      } else {
        bookImage.image = UIImage(named: "no_cover_thumb")
      }

      title.text = book.volumeInfo.title
    }
  }
  
  @IBOutlet var title: UILabel!
  @IBOutlet var bookImage: UIImageView!
  
}
