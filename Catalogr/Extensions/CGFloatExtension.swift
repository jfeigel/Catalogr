//
//  CGFloatExtension.swift
//  Catalogr
//
//  Created by jfeigel on 4/11/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

extension CGFloat {
  func toRadians() -> CGFloat {
    return self * CGFloat(Double.pi) / 180.0
  }
}
