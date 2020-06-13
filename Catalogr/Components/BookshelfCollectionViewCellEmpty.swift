//
//  BookshelfCollectionViewCellEmpty.swift
//  Catalogr
//
//  Created by jfeigel on 6/12/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class BookshelfCollectionViewCellEmpty: UICollectionViewCell {
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    layer.borderWidth = 1
    layer.borderColor = UIColor(named: "background")?.cgColor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    layer.borderColor = UIColor(named: "background")?.cgColor
  }
  
}
