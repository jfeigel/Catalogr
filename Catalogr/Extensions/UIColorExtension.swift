//
//  UIColorExtension.swift
//  Catalogr
//
//  Created by jfeigel on 4/11/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

extension UIColor {
  public convenience init?(hex: String) {
    let r, g, b, a: CGFloat
    var hexColor: String = hex.lowercased()
    
    if hexColor.hasPrefix("#") {
      let startIndex = hexColor.index(hexColor.startIndex, offsetBy: 1)
      hexColor = String(hexColor[startIndex...])
    }
    
    if hexColor.count == 6 {
      hexColor = "\(hexColor)ff"
    }
    
    if hexColor.count == 8 {
      let scanner = Scanner(string: hexColor)
      var hexNumber: UInt64 = 0
      
      if scanner.scanHexInt64(&hexNumber) {
        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
        a = CGFloat(hexNumber & 0x000000ff) / 255
        
        self.init(red: r, green: g, blue: b, alpha: a)
        return
      }
    }
    
    return nil
  }
}
