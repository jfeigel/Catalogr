//
//  SettingsViewController.swift
//  Catalogr
//
//  Created by jfeigel on 4/7/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return SceneDelegate.shared!.settings.rows.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return SceneDelegate.shared!.settings.rows[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let row = SceneDelegate.shared?.settings.rows[indexPath.section][indexPath.row] else {
      fatalError("Settings row not found")
    }

    switch row.cellType {
    case "SettingsPickerTableViewCell":
      guard let cell = tableView.dequeueReusableCell(withIdentifier: row.cellIdentifier, for: indexPath) as? SettingsPickerTableViewCell else {
        fatalError("The dequeued cell is not an instance of SettingsPickerTableViewCell")
      }
      
      cell.label.text = row.cellLabel
      
      for (i, style) in Settings.userInterfaceStyleDict.enumerated() {
        cell.segmentedControl.setTitle(style, forSegmentAt: i)
      }
      
      cell.segmentedControl.selectedSegmentIndex = SceneDelegate.shared!.settings.userInterfaceStyle
      cell.segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
      
      return cell
    case "SettingsToggleTableViewCell":
      guard let cell = tableView.dequeueReusableCell(withIdentifier: row.cellIdentifier, for: indexPath) as? SettingsToggleTableViewCell else {
        fatalError("The dequeued cell is not an instance of SettingsToggleTableViewCell")
      }
      
      cell.label.text = row.cellLabel
      
      cell.toggle.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
      
      return cell
    default: fatalError("Unknown Cell Type found: \(row.cellType)")
    }
  }
  
  @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
    SceneDelegate.shared!.settings.userInterfaceStyle = sender.selectedSegmentIndex
  }
  
  @objc func switchValueChanged(_ sender: UISwitch) {
    SceneDelegate.shared!.settings.performHapticFeedback = sender.isOn
  }
  
}
