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
    let imageView = UIImageView()
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
  
  let bookCheckmarkContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
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

    bookCheckmarkContainer.addSubview(bookCheckmarkBackground)
    bookCheckmarkContainer.addSubview(bookCheckmark)
    bookCheckmarkContainer.addSubview(bookCheckmarkBorder)
    
    contentView.addSubview(bookImage)
    contentView.addSubview(activityIndicator)
    contentView.addSubview(bookOverlay)
    contentView.addSubview(bookCheckmarkContainer)
    
    bookImage.topAnchor.constraint(equalTo: bookImage.superview!.topAnchor, constant: 20).isActive = true
    bookImage.leadingAnchor.constraint(equalTo: bookImage.superview!.leadingAnchor, constant: 20).isActive = true
    bookImage.trailingAnchor.constraint(equalTo: bookImage.superview!.trailingAnchor, constant: -20).isActive = true
    bookImage.bottomAnchor.constraint(equalTo: bookImage.superview!.bottomAnchor, constant: -20).isActive = true
    bookImage.centerXAnchor.constraint(equalTo: bookImage.superview!.centerXAnchor).isActive = true
    bookImage.centerYAnchor.constraint(equalTo: bookImage.superview!.centerYAnchor).isActive = true
    
    activityIndicator.centerXAnchor.constraint(equalTo: activityIndicator.superview!.centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: activityIndicator.superview!.centerYAnchor).isActive = true
    
    bookCheckmarkContainer.trailingAnchor.constraint(equalTo: bookCheckmarkContainer.superview!.trailingAnchor, constant: -15).isActive = true
    bookCheckmarkContainer.bottomAnchor.constraint(equalTo: bookCheckmarkContainer.superview!.bottomAnchor, constant: -15).isActive = true
  
    bookOverlay.topAnchor.constraint(equalTo: bookOverlay.superview!.topAnchor).isActive = true
    bookOverlay.leadingAnchor.constraint(equalTo: bookOverlay.superview!.leadingAnchor).isActive = true
    bookOverlay.trailingAnchor.constraint(equalTo: bookOverlay.superview!.trailingAnchor).isActive = true
    bookOverlay.bottomAnchor.constraint(equalTo: bookOverlay.superview!.bottomAnchor).isActive = true
    
    bookCheckmarkBorder.centerXAnchor.constraint(equalTo: bookCheckmarkBorder.superview!.centerXAnchor).isActive = true
    bookCheckmarkBorder.centerYAnchor.constraint(equalTo: bookCheckmarkBorder.superview!.centerYAnchor).isActive = true
    
    bookCheckmark.centerXAnchor.constraint(equalTo: bookCheckmark.superview!.centerXAnchor).isActive = true
    bookCheckmark.centerYAnchor.constraint(equalTo: bookCheckmark.superview!.centerYAnchor).isActive = true
    
    bookCheckmarkBackground.centerXAnchor.constraint(equalTo: bookCheckmarkBackground.superview!.centerXAnchor).isActive = true
    bookCheckmarkBackground.centerYAnchor.constraint(equalTo: bookCheckmarkBackground.superview!.centerYAnchor).isActive = true
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
  
}
