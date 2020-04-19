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
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = SceneDelegate.shared?.settings.rows[indexPath.row] as! Settings.Row<SettingsPickerTableViewCell>
    guard let cell = tableView.dequeueReusableCell(withIdentifier: row.description, for: indexPath) as? SettingsPickerTableViewCell else {
      fatalError("The dequeued cell is not an instance of SettingsPickerTableViewCell")
    }
    
    cell.label.text = row.name
    
    for (i, style) in Settings.userInterfaceStyleDict.enumerated() {
      cell.segmentedControl.setTitle(style, forSegmentAt: i)
    }
    
    cell.segmentedControl.selectedSegmentIndex = SceneDelegate.shared!.settings.userInterfaceStyle
    cell.segmentedControl.addTarget(self, action: #selector(changeSegmenetedControl(_:)), for: .valueChanged)
    
    return cell
  }
  
  @objc func changeSegmenetedControl(_ sender: UISegmentedControl) {
    SceneDelegate.shared?.settings.userInterfaceStyle = sender.selectedSegmentIndex
  }
  
}
