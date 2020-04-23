//
//  Constraints.swift
//  Catalogr
//
//  Created by jfeigel on 4/22/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

struct Constraints: Loopable {
  var topAnchor: NSLayoutConstraint?
  var leadingAnchor: NSLayoutConstraint?
  var trailingAnchor: NSLayoutConstraint?
  var bottomAnchor: NSLayoutConstraint?
  var centerXAnchor: NSLayoutConstraint?
  var centerYAnchor: NSLayoutConstraint?
  var width: NSLayoutConstraint?
  var height: NSLayoutConstraint?
  
  subscript(key: String) -> NSLayoutConstraint? {
    get {
      switch key {
      case "topAnchor": return self.topAnchor
      case "leadingAnchor": return self.leadingAnchor
      case "trailingAnchor": return self.trailingAnchor
      case "bottomAnchor": return self.bottomAnchor
      case "centerXAnchor": return self.centerXAnchor
      case "centerYAnchor": return self.centerYAnchor
      case "width": return self.width
      case "height": return self.height
      default: fatalError("Unknown key found for Constraints: \(key)")
      }
    }
    set {
      switch key {
      case "topAnchor": self.topAnchor = newValue
      case "leadingAnchor": self.leadingAnchor = newValue
      case "trailingAnchor": self.trailingAnchor = newValue
      case "bottomAnchor": self.bottomAnchor = newValue
      case "centerXAnchor": self.centerXAnchor = newValue
      case "centerYAnchor": self.centerYAnchor = newValue
      case "width": self.width = newValue
      case "height": self.height = newValue
      default: fatalError("Unknown key found for Constraints: \(key)")
      }
    }
  }
}
