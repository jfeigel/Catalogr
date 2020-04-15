//
//  BookshelfCollectionViewCell.swift
//  Catalogr
//
//  Created by jfeigel on 4/14/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class BookshelfCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var bookImage: UIImageView!
  @IBOutlet weak var bookOverlay: UIView!
  @IBOutlet var bookCheckmark: UIImageView!
  
  var isInEditingMode: Bool = false {
    didSet {
      bookOverlay.isHidden = !isInEditingMode
      bookCheckmark.isHidden = !isInEditingMode
    }
  }
  
  override var isSelected: Bool {
    didSet {
      if isInEditingMode {
        bookCheckmark.isHighlighted = isSelected
        if isSelected {
          bookCheckmark.backgroundColor = .white
          bookCheckmark.tintColor = nil
        } else {
          bookCheckmark.backgroundColor = nil
          bookCheckmark.tintColor = .white
        }
      }
    }
  }
  
}
