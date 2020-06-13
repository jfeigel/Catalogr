//
//  SearchTableViewCell.swift
//  Catalogr
//
//  Created by jfeigel on 4/22/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
  
  @IBOutlet var container: UIView!
  @IBOutlet var title: UILabel!
  @IBOutlet var bookImage: UIImageView!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  
  var book: Book! {
    didSet {
      if
        let imageLinks = book.volumeInfo.imageLinks,
        let thumbnail = imageLinks.thumbnail
      {
        bookImage.isHidden = true
        activityIndicator.startAnimating()
        bookImage.load(url: URL(string: thumbnail)!) { _ in
          self.activityIndicator.stopAnimating()
          self.bookImage.isHidden = false
        }
      } else {
        bookImage.image = UIImage(named: "no_cover_thumb")
      }

      title.text = book.volumeInfo.title
    }
  }
  
  override func prepareForReuse() {
    title.text = nil
    bookImage.image = nil
  }
  
}
