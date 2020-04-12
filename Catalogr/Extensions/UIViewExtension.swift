//
//  UIViewExtension.swift
//  Catalogr
//
//  Created by jfeigel on 4/9/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

extension UIView {
  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}
