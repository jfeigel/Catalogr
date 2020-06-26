//
//  BookshelfCollectionViewCellEmpty.swift
//  Catalogr
//
//  Created by jfeigel on 6/12/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class BookshelfCollectionViewCellEmpty: UICollectionViewCell {
  
  let overlay: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleToFill
    view.backgroundColor = .black
    view.alpha = 0.2
    return view
  }()
  
  var isInEditingMode: Bool = false
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    layer.borderWidth = 1
    layer.borderColor = UIColor(named: "background")?.cgColor
    
    contentView.addSubview(overlay)
    
    overlay.topAnchor.constraint(equalTo: overlay.superview!.topAnchor).isActive = true
    overlay.leadingAnchor.constraint(equalTo: overlay.superview!.leadingAnchor).isActive = true
    overlay.trailingAnchor.constraint(equalTo: overlay.superview!.trailingAnchor).isActive = true
    overlay.bottomAnchor.constraint(equalTo: overlay.superview!.bottomAnchor).isActive = true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    layer.borderColor = UIColor(named: "background")?.cgColor
  }
  
}
