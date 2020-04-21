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
  var isEmpty: Bool = false {
    didSet {
      if isEmpty {
        self.isInEditingMode = false
        self.bookImage.isHidden = true
        self.isRead.isHidden = true
        self.isBorrowed.isHidden = true
      }
    }
  }
  
  let cellBackground: CAGradientLayer = {
    let layer = CAGradientLayer()
    layer.locations = [0.0, 0.7, 0.7, 1.0]
    layer.anchorPoint = .zero
    return layer
  }()
  
  let bookImage: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "no_cover_thumb"))
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  let activityIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let bookOverlay: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleToFill
    view.backgroundColor = .white
    view.alpha = 0.2
    return view
  }()
  
  let actionContainer: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    stackView.spacing = 12.5
    return stackView
  }()
  
  let isBorrowed: UIImageView = {
    let imageView = UIImageView(
      image: UIImage(systemName: "tray.and.arrow.up"),
      highlightedImage: UIImage(systemName: "tray.and.arrow.up.fill")
    )
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .white
    return imageView
  }()
  
  let isRead: UIImageView = {
    let imageView = UIImageView(
      image: UIImage(systemName: "book"),
      highlightedImage: UIImage(systemName: "book.fill")
    )
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .white
    return imageView
  }()
  
  let bookCheckmarkContainer = UIView()
  
  let bookCheckmarkBorder: UIImageView = {
    let imageView = UIImageView(
      image: UIImage(systemName: "circle")
    )
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.tintColor = .white
    imageView.layer.cornerRadius = imageView.frame.size.width / 2
    return imageView
  }()
  
  let bookCheckmark: UIImageView = {
    let imageView = UIImageView(
      image: UIImage(systemName: "checkmark.circle.fill")
    )
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.layer.cornerRadius = imageView.frame.size.width / 2
    return imageView
  }()
  
  let bookCheckmarkBackground: UIImageView = {
    let imageView = UIImageView(
      image: UIImage(systemName: "checkmark.circle")
    )
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.tintColor = .white
    imageView.layer.cornerRadius = imageView.frame.size.width / 2
    return imageView
  }()

  fileprivate var bookImageConstraints: Constraints!
  fileprivate var bookOverlayConstraints: Constraints!
  fileprivate var actionContainerConstraints: Constraints!
  fileprivate var bookCheckmarkBorderConstraints: Constraints!
  fileprivate var bookCheckmarkConstraints: Constraints!
  fileprivate var bookCheckmarkBackgroundConstraints: Constraints!
  
  var isInEditingMode: Bool = false {
    didSet {
      isSelected = false
      
      isRead.alpha = isInEditingMode ? 0.5 : 1.0
      isBorrowed.alpha = isInEditingMode ? 0.5 : 1.0
      
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

    bookCheckmarkContainer.addSubview(bookCheckmarkBackground)
    bookCheckmarkContainer.addSubview(bookCheckmark)
    bookCheckmarkContainer.addSubview(bookCheckmarkBorder)
    
    actionContainer.addArrangedSubview(isRead)
    actionContainer.addArrangedSubview(isBorrowed)
    actionContainer.addArrangedSubview(bookCheckmarkContainer)
    
    contentView.addSubview(bookImage)
    contentView.addSubview(activityIndicator)
    contentView.addSubview(bookOverlay)
    contentView.addSubview(actionContainer)
    
    bookImageConstraints = Constraints(
      topAnchor: bookImage.topAnchor.constraint(equalTo: bookImage.superview!.topAnchor, constant: 20),
      leadingAnchor: bookImage.leadingAnchor.constraint(equalTo: bookImage.superview!.leadingAnchor, constant: 20),
      trailingAnchor: bookImage.trailingAnchor.constraint(equalTo: bookImage.superview!.trailingAnchor, constant: -20),
      bottomAnchor: bookImage.bottomAnchor.constraint(equalTo: bookImage.superview!.bottomAnchor, constant: -20),
      centerXAnchor: bookImage.centerXAnchor.constraint(equalTo: bookImage.superview!.centerXAnchor),
      centerYAnchor: bookImage.centerYAnchor.constraint(equalTo: bookImage.superview!.centerYAnchor)
    )
    
    for constraint in bookImageConstraints.keys() {
      if let validConstraint = bookImageConstraints[constraint] {
        validConstraint.isActive = true
      }
    }
    
    activityIndicator.centerXAnchor.constraint(equalTo: activityIndicator.superview!.centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: activityIndicator.superview!.centerYAnchor).isActive = true
    
    actionContainerConstraints = Constraints(
      topAnchor: actionContainer.topAnchor.constraint(equalTo: actionContainer.superview!.topAnchor, constant: 12.5),
      trailingAnchor: actionContainer.trailingAnchor.constraint(equalTo: actionContainer.superview!.trailingAnchor, constant: -12.5),
      bottomAnchor: actionContainer.bottomAnchor.constraint(equalTo: actionContainer.superview!.bottomAnchor, constant: -12.5)
    )
    
    for constraint in actionContainerConstraints.keys() {
      if let validConstraint = actionContainerConstraints[constraint] {
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
      centerXAnchor: bookCheckmarkBorder.centerXAnchor.constraint(equalTo: bookCheckmarkBorder.superview!.centerXAnchor),
      centerYAnchor: bookCheckmarkBorder.centerYAnchor.constraint(equalTo: bookCheckmarkBorder.superview!.centerYAnchor)
    )
    
    for constraint in bookCheckmarkBorderConstraints.keys() {
      if let validConstraint = bookCheckmarkBorderConstraints[constraint] {
        validConstraint.isActive = true
      }
    }
    
    bookCheckmarkConstraints = Constraints(
        centerXAnchor: bookCheckmark.centerXAnchor.constraint(equalTo: bookCheckmark.superview!.centerXAnchor),
        centerYAnchor: bookCheckmark.centerYAnchor.constraint(equalTo: bookCheckmark.superview!.centerYAnchor)
    )
    
    for constraint in bookCheckmarkConstraints.keys() {
      if let validConstraint = bookCheckmarkConstraints[constraint] {
        validConstraint.isActive = true
      }
    }
    
    bookCheckmarkBackgroundConstraints = Constraints(
        centerXAnchor: bookCheckmarkBackground.centerXAnchor.constraint(equalTo: bookCheckmarkBackground.superview!.centerXAnchor),
        centerYAnchor: bookCheckmarkBackground.centerYAnchor.constraint(equalTo: bookCheckmarkBackground.superview!.centerYAnchor)
    )
    
    for constraint in bookCheckmarkBackgroundConstraints.keys() {
      if let validConstraint = bookCheckmarkBackgroundConstraints[constraint] {
        validConstraint.isActive = true
      }
    }
    
    bookImage.dropShadow(type: "book")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

    if traitCollection.userInterfaceStyle == .light {
      cellBackground.colors = [
        UIColor.systemGray2.cgColor,
        UIColor.systemGray3.cgColor,
        UIColor.systemGray.cgColor,
        UIColor.systemGray3.cgColor
      ]
    } else {
      cellBackground.colors = [
        UIColor.systemGray5.cgColor,
        UIColor.systemGray4.cgColor,
        UIColor.systemGray6.cgColor,
        UIColor.systemGray4.cgColor
      ]
    }

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
