//
//  SearchTableViewCell.swift
//  Catalogr
//
//  Created by jfeigel on 4/22/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
  
  @IBOutlet var title: UILabel!
  @IBOutlet var bookImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
