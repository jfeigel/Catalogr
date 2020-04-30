//
//  RoundFillButton.swift
//  Catalogr
//
//  Created by jfeigel on 4/30/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

@IBDesignable class RoundFillButton: UIButton {

  override func layoutSubviews() {
    super.layoutSubviews()
    
    updateButton()
  }
  
  @IBInspectable var rounded: Bool = false {
    didSet {
      updateButton()
    }
  }
  
  func updateButton() {
    layer.cornerRadius = rounded ? frame.size.height / 2 : 0
  }

}
