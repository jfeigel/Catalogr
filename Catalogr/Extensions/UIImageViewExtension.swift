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
    URLSession.shared.dataTask(with: url) { [weak self] data, res, err in
      guard
        let httpURLResponse = res as? HTTPURLResponse, httpURLResponse.statusCode == 200,
        let mimeType = res?.mimeType, mimeType.hasPrefix("image"),
        let data = data, err == nil,
        let image = UIImage(data: data)
      else {
        os_log("Error while trying to retrieve data from %s", type: .error, url as CVarArg)
        return
      }
      
      DispatchQueue.main.async() {
        self?.image = image
        if completion != nil {
          completion!(image)
        }
      }
    }.resume()
  }
  
  enum ShadowTypes {
    case drop, oval, book
  }
  
  func dropShadow(type: ShadowTypes = .drop) {
    self.layer.masksToBounds = false
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOpacity = 0.5
    self.layer.shouldRasterize = true
    self.layer.rasterizationScale = UIScreen.main.scale
    
    let size = self.frame.size
    
    switch type {
    case .oval:
      let shadowSize: CGFloat = 20
      let ovalRect = CGRect(x: -shadowSize, y: size.height - (shadowSize * 0.4), width: size.width + shadowSize * 2, height: shadowSize)
      self.layer.shadowPath = UIBezierPath(ovalIn: ovalRect).cgPath
      self.layer.shadowRadius = 5
    case .book:
      let shadowSize: CGFloat = 20
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
