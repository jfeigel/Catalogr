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
  func load(url: URL, resize: CGFloat = 0, completion: ((UIImage) -> ())? = nil) {
    let _ = ImageLoader.shared.loadImage(from: url)
      .sink { [unowned self] image in
        if let image = image {
          self.image = resize != 0 ? image.resize(resize) : image
          if let completion = completion {
            DispatchQueue.main.async {
              completion(self.image!)
            }
          }
        }
      }
  }
  
  enum ShadowTypes {
    case drop, oval, ovalAlt, book
  }
  
  func dropShadow(type: ShadowTypes = .drop, shadowSize: CGFloat = 20) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.layer.masksToBounds = false
      self.layer.shadowColor = UIColor.black.cgColor
      self.layer.shadowOpacity = 0.5
      self.layer.shouldRasterize = true
      self.layer.rasterizationScale = UIScreen.main.scale
      
      let imageViewSize = self.frame.size
      guard let imageSize = self.image?.size else {
        return
      }
      
      switch type {
      case .drop:
        self.layer.shadowOffset = .zero
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
      case .oval:
        let ovalRect = CGRect(x: -shadowSize, y: imageSize.height - (shadowSize * 0.4), width: imageSize.width + shadowSize * 2, height: shadowSize)
        self.layer.shadowPath = UIBezierPath(ovalIn: ovalRect).cgPath
        self.layer.shadowRadius = 5
      case .ovalAlt:
        let ovalRect = CGRect(x: 0, y: (imageSize.height * 2) - (shadowSize * 2.25), width: (imageSize.width * 2) + (shadowSize * 1.5), height: shadowSize)
        self.layer.shadowPath = UIBezierPath(ovalIn: ovalRect).cgPath
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 1.0 / 3.0
      case .book:
        self.layer.shadowOffset = .zero
        let imageBounds = CGRect(origin: CGPoint(x: (imageViewSize.width - imageSize.width - shadowSize) / 2, y: (imageViewSize.height - imageSize.height - shadowSize) / 2), size: CGSize(width: imageSize.width + shadowSize, height: imageSize.height + shadowSize))
        self.layer.shadowPath = UIBezierPath(roundedRect: imageBounds, cornerRadius: shadowSize).cgPath
        self.layer.shadowRadius = shadowSize
        self.layer.shadowOpacity = 0.25
      }
    }
  }

}
