//
//  RoundView.swift
//  Catalogr
//
//  Created by jfeigel on 6/13/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

@IBDesignable class RoundView: UIView {

  override func layoutSubviews() {
    super.layoutSubviews()
    
    updateCell()
  }
  
  @IBInspectable var radius: CGFloat = 0 {
    didSet {
      updateCell()
    }
  }
  
  func updateCell() {
    layer.cornerRadius = radius
  }

}
