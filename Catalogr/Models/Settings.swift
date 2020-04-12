//
//  Settings.swift
//  Catalogr
//
//  Created by jfeigel on 4/7/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

final class Settings {
  
  static var userInterfaceStyleDict: [String] = ["System", "Light", "Dark"]

  var rows = [Any]()
  
  var userInterfaceStyle: Int {
    didSet {
      setUserInterfaceStyle(index: userInterfaceStyle)
    }
  }
  
  init() {
    userInterfaceStyle = (SceneDelegate.shared?.window!.overrideUserInterfaceStyle.rawValue)!
    setUserInterfaceStyle(index: userInterfaceStyle)

    let userInterfaceStyleRow = Row<SettingsPickerTableViewCell>(name: "User Interface Style", type: SettingsPickerTableViewCell(), description: "SettingsPickerTableViewCell")
    rows.append(userInterfaceStyleRow)
  }
  
  func setUserInterfaceStyle(index: Int) {
    SceneDelegate.shared?.window!.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: userInterfaceStyle)!
  }
  
  struct Row<T> {
    var name: String = ""
    var type: T
    var description: String = ""
  }
}
