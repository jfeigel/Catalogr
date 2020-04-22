//
//  UIImageExtension.swift
//  Catalogr
//
//  Created by jfeigel on 4/21/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

extension UIImage {
  func resize(_ maxDimension: CGFloat, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
    var width: CGFloat
    var height: CGFloat
    var newImage: UIImage
    
    let size = self.size
    let aspectRatio: CGFloat = size.width / size.height
    
    switch contentMode {
    case .scaleAspectFit:
      if aspectRatio > 1 {
        width = maxDimension
        height = maxDimension / aspectRatio
      } else {
        width = maxDimension * aspectRatio
        height = maxDimension
      }
    default:
      fatalError("UIImage.resize(): FATAL: Unimplemented ContentMode")
    }
    
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
    newImage = renderer.image { context in
      self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    return newImage
  }
}
