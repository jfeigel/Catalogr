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
  
  @IBInspectable var radius: CGFloat = 0 {
    didSet {
      updateButton()
    }
  }
  
  @IBInspectable var dropShadow: Bool = false {
    didSet {
      updateButton()
    }
  }
  
  @IBInspectable var shadowRadius: CGFloat = 0 {
    didSet {
      updateButton()
    }
  }
  
  func updateButton() {
    if rounded == true {
      layer.cornerRadius = radius != 0 ? radius : frame.size.height / 2
    } else {
      layer.cornerRadius = 0
    }
    
    if dropShadow {
      layer.masksToBounds = false
      layer.shadowColor = UIColor.black.cgColor
      layer.shadowOffset = .zero//CGSize(width: 0, height: 2)
      layer.shadowOpacity = 0.5
      layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
      layer.shadowRadius = shadowRadius
      layer.shouldRasterize = true
      layer.rasterizationScale = UIScreen.main.scale
    }
  }

}
