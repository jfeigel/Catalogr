//
//  Settings.swift
//  Catalogr
//
//  Created by jfeigel on 4/7/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit
import os.log

class Settings: NSObject, NSCoding {
  static let shared = Settings(decodedUserInterfaceStyle: -1)
  
  // MARK: - Properties
  
  static var userInterfaceStyleDict: [String] = ["System", "Light", "Dark"]

  var rows = [[Row]]()
  
  var userInterfaceStyle: Int {
    didSet {
      setAndArchiveSettings()
    }
  }
  
  var performHapticFeedback: Bool = true
  
  struct Row {
    var cellLabel: String = ""
    var cellType: String = ""
    var cellIdentifier: String = ""
  }
  
  // MARK: - Types
  
  struct PropertyKey {
    static let userInterfaceStyle = "userInterfaceStyle"
  }
  
  // MARK: - Archiving Path
  
  static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.appendingPathComponent("settings")
  
  // MARK: - Init
  
  override init() {
    self.userInterfaceStyle = -1
    
    self.rows = [
      [
        Row(cellLabel: "User Interface Style", cellType: "SettingsPickerTableViewCell", cellIdentifier: "SettingsPickerTableViewCell"),
        Row(cellLabel: "Haptic Feedback", cellType: "SettingsToggleTableViewCell", cellIdentifier: "SettingsToggleTableViewCell")
      ]
    ]
  }

  convenience init(decodedUserInterfaceStyle: Int = -1) {
    self.init()

    if decodedUserInterfaceStyle >= 0 {
      userInterfaceStyle = decodedUserInterfaceStyle
    } else {
      do {
        let data = try Data(contentsOf: Settings.ArchiveURL)
        userInterfaceStyle = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Int ?? -1
      } catch {
        os_log("Failed to load Settings", log: OSLog.default, type: .error)
        userInterfaceStyle = (SceneDelegate.shared?.window!.overrideUserInterfaceStyle.rawValue)!
      }
    }
    
    setAndArchiveSettings()
  }
  
  // MARK: - Methods
  
  private func setAndArchiveSettings() {
    SceneDelegate.shared?.window!.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: userInterfaceStyle)!
    
    do {
      let data = try NSKeyedArchiver.archivedData(withRootObject: userInterfaceStyle, requiringSecureCoding: false)
      try data.write(to: Settings.ArchiveURL)
    } catch {
      os_log("Failed to save Settings", log: OSLog.default, type: .error)
    }
  }
  
  // MARK: - NSCoding
  
  func encode(with coder: NSCoder) {
    coder.encode(userInterfaceStyle, forKey: PropertyKey.userInterfaceStyle)
  }
  
  required convenience init?(coder decoder: NSCoder) {
    let decodedUserInterfaceStyle = decoder.decodeInteger(forKey: PropertyKey.userInterfaceStyle)
    self.init(decodedUserInterfaceStyle: decodedUserInterfaceStyle)
  }
}
