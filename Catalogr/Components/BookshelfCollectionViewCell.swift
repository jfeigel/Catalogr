//
//  BookshelfCollectionViewCell.swift
//  Catalogr
//
//  Created by jfeigel on 4/14/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class BookshelfCollectionViewCell: UICollectionViewCell {
  
  var sublayerInserted = false
  
  let cellBackground: CAGradientLayer = {
    let gl = CAGradientLayer()
    gl.locations = [0.7, 1.0]
    gl.anchorPoint = .zero
    return gl
  }()
  
  let bookImage: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "no_cover_thumb"))
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  let bookOverlay: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleToFill
    view.backgroundColor = .white
    view.alpha = 0.2
    return view
  }()
  
  let bookCheckmarkBorder: UIImageView = {
    let imageView = UIImageView(
      image: UIImage(systemName: "circle")
    )
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.tintColor = .white
    imageView.layer.cornerRadius = imageView.frame.size.width / 2
    return imageView
  }()
  
  let bookCheckmark: UIImageView = {
    let imageView = UIImageView(
      image: UIImage(systemName: "checkmark.circle.fill")
    )
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = imageView.frame.size.width / 2
    return imageView
  }()
  
  let bookCheckmarkBackground: UIImageView = {
    let imageView = UIImageView(
      image: UIImage(systemName: "checkmark.circle")
    )
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.tintColor = .white
    imageView.layer.cornerRadius = imageView.frame.size.width / 2
    return imageView
  }()
  

  fileprivate var bookImageConstraints: Constraints!
  fileprivate var bookOverlayConstraints: Constraints!
  fileprivate var bookCheckmarkBorderConstraints: Constraints!
  fileprivate var bookCheckmarkConstraints: Constraints!
  fileprivate var bookCheckmarkBackgroundConstraints: Constraints!
  
  var isInEditingMode: Bool = false {
    didSet {
      isSelected = false
      bookOverlay.isHidden = !isInEditingMode || !isSelected
      bookCheckmarkBorder.isHidden = !isInEditingMode
      bookCheckmark.isHidden = !isInEditingMode || !isSelected
      bookCheckmarkBackground.isHidden = !isInEditingMode || !isSelected
    }
  }
  
  override var isSelected: Bool {
    didSet {
      if isInEditingMode {
        bookOverlay.isHidden = !isSelected
        bookCheckmark.isHidden = !isSelected
        bookCheckmarkBackground.isHidden = !isSelected
      }
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    contentMode = .scaleAspectFit
    contentView.contentMode = .center
    contentView.layer.borderWidth = 1.0
    contentView.layer.borderColor = UIColor.label.cgColor
    
    contentView.addSubview(bookImage)
    contentView.addSubview(bookOverlay)
    contentView.addSubview(bookCheckmarkBackground)
    contentView.addSubview(bookCheckmark)
    contentView.addSubview(bookCheckmarkBorder)
    
    bookImageConstraints = Constraints(
      topAnchor: bookImage.topAnchor.constraint(equalTo: bookImage.superview!.topAnchor, constant: 10),
      leadingAnchor: bookImage.leadingAnchor.constraint(equalTo: bookImage.superview!.leadingAnchor, constant: 10),
      trailingAnchor: bookImage.trailingAnchor.constraint(equalTo: bookImage.superview!.trailingAnchor, constant: -10),
      bottomAnchor: bookImage.bottomAnchor.constraint(equalTo: bookImage.superview!.bottomAnchor, constant: -10),
      centerXAnchor: bookImage.centerXAnchor.constraint(equalTo: bookImage.superview!.centerXAnchor),
      centerYAnchor: bookImage.centerYAnchor.constraint(equalTo: bookImage.superview!.centerYAnchor)
    )
    
    for constraint in bookImageConstraints.keys() {
      if let validConstraint = bookImageConstraints[constraint] {
        validConstraint.isActive = true
      }
    }
    
    bookOverlayConstraints = Constraints(
      topAnchor: bookOverlay.topAnchor.constraint(equalTo: bookOverlay.superview!.topAnchor),
      leadingAnchor: bookOverlay.leadingAnchor.constraint(equalTo: bookOverlay.superview!.leadingAnchor),
      trailingAnchor: bookOverlay.trailingAnchor.constraint(equalTo: bookOverlay.superview!.trailingAnchor),
      bottomAnchor: bookOverlay.bottomAnchor.constraint(equalTo: bookOverlay.superview!.bottomAnchor)
    )
    
    for constraint in bookOverlayConstraints.keys() {
      if let validConstraint = bookOverlayConstraints[constraint] {
        validConstraint.isActive = true
      }
    }
    
    bookCheckmarkBorderConstraints = Constraints(
      trailingAnchor: bookCheckmarkBorder.trailingAnchor.constraint(equalTo: bookCheckmarkBorder.superview!.trailingAnchor, constant: -15),
      bottomAnchor: bookCheckmarkBorder.bottomAnchor.constraint(equalTo: bookCheckmarkBorder.superview!.bottomAnchor, constant: -15)
    )
    
    for constraint in bookCheckmarkBorderConstraints.keys() {
      if let validConstraint = bookCheckmarkBorderConstraints[constraint] {
        validConstraint.isActive = true
      }
    }
    
    bookCheckmarkConstraints = Constraints(
      trailingAnchor: bookCheckmark.trailingAnchor.constraint(equalTo: bookCheckmark.superview!.trailingAnchor, constant: -15),
      bottomAnchor: bookCheckmark.bottomAnchor.constraint(equalTo: bookCheckmark.superview!.bottomAnchor, constant: -15)
    )
    
    for constraint in bookCheckmarkConstraints.keys() {
      if let validConstraint = bookCheckmarkConstraints[constraint] {
        validConstraint.isActive = true
      }
    }
    
    bookCheckmarkBackgroundConstraints = Constraints(
      trailingAnchor: bookCheckmarkBackground.trailingAnchor.constraint(equalTo: bookCheckmarkBackground.superview!.trailingAnchor, constant: -15),
      bottomAnchor: bookCheckmarkBackground.bottomAnchor.constraint(equalTo: bookCheckmarkBackground.superview!.bottomAnchor, constant: -15)
    )
    
    for constraint in bookCheckmarkBackgroundConstraints.keys() {
      if let validConstraint = bookCheckmarkBackgroundConstraints[constraint] {
        validConstraint.isActive = true
      }
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

    cellBackground.colors = [
      UIColor.clear.cgColor,
      UIColor.systemGray5.cgColor
    ]

    if !sublayerInserted {
      sublayerInserted = true
      cellBackground.frame = contentView.frame
      contentView.layer.insertSublayer(cellBackground, at: 0)
    }
  }
  
  fileprivate struct Constraints: Loopable {
    var topAnchor: NSLayoutConstraint?
    var leadingAnchor: NSLayoutConstraint?
    var trailingAnchor: NSLayoutConstraint?
    var bottomAnchor: NSLayoutConstraint?
    var centerXAnchor: NSLayoutConstraint?
    var centerYAnchor: NSLayoutConstraint?
    var width: NSLayoutConstraint?
    var height: NSLayoutConstraint?
    
    subscript(key: String) -> NSLayoutConstraint? {
      get {
        switch key {
        case "topAnchor": return self.topAnchor
        case "leadingAnchor": return self.leadingAnchor
        case "trailingAnchor": return self.trailingAnchor
        case "bottomAnchor": return self.bottomAnchor
        case "centerXAnchor": return self.centerXAnchor
        case "centerYAnchor": return self.centerYAnchor
        case "width": return self.width
        case "height": return self.height
        default: fatalError("Unknown key found for Constraints: \(key)")
        }
      }
      set {
        switch key {
        case "topAnchor": self.topAnchor = newValue
        case "leadingAnchor": self.leadingAnchor = newValue
        case "trailingAnchor": self.trailingAnchor = newValue
        case "bottomAnchor": self.bottomAnchor = newValue
        case "centerXAnchor": self.centerXAnchor = newValue
        case "centerYAnchor": self.centerYAnchor = newValue
        case "width": self.width = newValue
        case "height": self.height = newValue
        default: fatalError("Unknown key found for Constraints: \(key)")
        }
      }
    }
  }
  
}
