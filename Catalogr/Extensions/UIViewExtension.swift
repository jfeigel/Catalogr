//
//  UIViewExtension.swift
//  Catalogr
//
//  Created by jfeigel on 4/9/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

extension UIView {
  func roundCorners(corners: UIRectCorner, radius: CGFloat!) {
    let cornerRadii: CGSize!

    if radius != nil {
      cornerRadii = CGSize(width: radius, height: radius)
    } else {
      let width = layer.frame.size.width * 0.15
      let height = layer.frame.size.height * 0.15
      cornerRadii = CGSize(width: width, height: height)
    }
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}
