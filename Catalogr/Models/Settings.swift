//
//  Settings.swift
//  Catalogr
//
//  Created by jfeigel on 4/7/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

final class Settings {
  var userInterfaceStyle: Int {
    didSet {
      UIApplication.shared.windows[0].overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: userInterfaceStyle)!
    }
  }
  
  var rows = [Any]()
  
  static var userInterfaceStyleDict: [String] = ["System", "Light", "Dark"]
  
  init() {
    userInterfaceStyle = UIApplication.shared.windows[0].overrideUserInterfaceStyle.rawValue
    let userInterfaceStyleRow = Row<SettingsPickerTableViewCell>(name: "User Interface Style", type: SettingsPickerTableViewCell(), description: "SettingsPickerTableViewCell", value: userInterfaceStyle)
    rows.append(userInterfaceStyleRow)
  }
  
  struct Row<T> {
    var name: String = ""
    var type: T
    var description: String = ""
    var value: Int
  }
}
