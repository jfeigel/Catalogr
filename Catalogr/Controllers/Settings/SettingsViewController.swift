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
    return Settings.shared.rows.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Settings.shared.rows[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = Settings.shared.rows[indexPath.section][indexPath.row]

    switch row.cellType {
    case "SettingsPickerTableViewCell":
      guard let cell = tableView.dequeueReusableCell(withIdentifier: row.cellIdentifier, for: indexPath) as? SettingsPickerTableViewCell else {
        fatalError("The dequeued cell is not an instance of SettingsPickerTableViewCell")
      }
      
      cell.label.text = row.cellLabel
      
      for (i, style) in Settings.userInterfaceStyleDict.enumerated() {
        cell.segmentedControl.setTitle(style, forSegmentAt: i)
      }
      
      cell.segmentedControl.selectedSegmentIndex = Settings.shared.userInterfaceStyle
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
    Settings.shared.userInterfaceStyle = sender.selectedSegmentIndex
  }
  
  @objc func switchValueChanged(_ sender: UISwitch) {
    Settings.shared.performHapticFeedback = sender.isOn
  }
  
}
