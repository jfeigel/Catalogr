//
//  SettingsToggleTableViewCell.swift
//  Catalogr
//
//  Created by jfeigel on 4/7/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class SettingsToggleTableViewCell: UITableViewCell {

  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var toggle: UISwitch!

  @IBAction func toggleAction(_ sender: UISwitch) {
  }

  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
