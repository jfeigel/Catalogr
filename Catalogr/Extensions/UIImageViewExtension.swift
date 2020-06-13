//
//  UIImageViewExtension.swift
//  Catalogr
//
//  Created by jfeigel on 3/31/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit
import os.log

extension UIImageView {
  func load(url: URL, completion: ((UIImage) -> ())? = nil) {
    let _ = ImageLoader.shared.loadImage(from: url)
      .sink { [unowned self] image in
        if let image = image {
          self.image = image
          if completion != nil {
            completion!(image)
          }
        }
      }
  }
  
  enum ShadowTypes {
    case drop, oval, book
  }
  
  func dropShadow(type: ShadowTypes = .drop, shadowSize: CGFloat = 20) {
    self.layer.masksToBounds = false
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOpacity = 0.5
    self.layer.shouldRasterize = true
    self.layer.rasterizationScale = UIScreen.main.scale
    
    let size = self.frame.size
    
    switch type {
    case .oval:
      let shadowSize: CGFloat = shadowSize
      let ovalRect = CGRect(x: -shadowSize, y: size.height - (shadowSize * 0.8), width: size.width + shadowSize * 2, height: shadowSize)
      self.layer.shadowPath = UIBezierPath(ovalIn: ovalRect).cgPath
      self.layer.shadowRadius = 5
    case .book:
      let shadowSize: CGFloat = shadowSize
      let ovalRect = CGRect(x: 0, y: (size.height * 2) - (shadowSize * 2.25), width: (size.width * 2) + (shadowSize * 1.5), height: shadowSize)
      self.layer.shadowPath = UIBezierPath(ovalIn: ovalRect).cgPath
      self.layer.shadowRadius = 5
      self.layer.shadowOpacity = 1.0 / 3.0
    case .drop:
      self.layer.shadowOffset = .zero
      self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
  }

}
