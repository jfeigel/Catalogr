//
//  BookshelfCollectionViewCell.swift
//  Catalogr
//
//  Created by jfeigel on 4/14/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class BookshelfCollectionViewCell: UICollectionViewCell {
  
  let propContainer: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.spacing = 0
    return stackView
  }()
  
  let readIcon: UIImageView = {
    let imageView = UIImageView(
      image: UIImage(systemName: "book", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12))
    )
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .center
    return imageView
  }()
  
  let borrowedIcon: UIImageView = {
    let imageView = UIImageView(
      image: UIImage(systemName: "square.and.arrow.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12)),
      highlightedImage: UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12))
    )
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .center
    return imageView
  }()
  
  let ratingContainer: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.alignment = .trailing
    stackView.distribution = .fill
    stackView.spacing = 0
    return stackView
  }()
  
  let ratingStar: UIImageView = {
    let imageView = UIImageView(
      image: UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12))
    )
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.tintColor = .systemGray2
    imageView.contentMode = .center
    return imageView
  }()
  
  let ratingValue: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "-"
    label.textColor = .systemGray2
    label.font = label.font.withSize(12)
    return label
  }()
  
  let bookImage: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  let bookTitle: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.numberOfLines = 0
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
    return label
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
    imageView.tintColor = .systemGray3
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
        bookCheckmarkBorder.tintColor = isSelected ? nil : .systemGray3
        bookCheckmark.isHidden = !isSelected
        bookCheckmarkBackground.isHidden = !isSelected
      }
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    layer.borderWidth = 1
    layer.borderColor = UIColor(named: "background")?.cgColor
    
    contentMode = .scaleAspectFit
    contentView.contentMode = .center
    
    ratingContainer.addArrangedSubview(ratingStar)
    ratingContainer.addArrangedSubview(ratingValue)
    
    propContainer.addArrangedSubview(readIcon)
    propContainer.addArrangedSubview(borrowedIcon)
    propContainer.addArrangedSubview(ratingContainer)

    bookCheckmarkContainer.addSubview(bookCheckmarkBackground)
    bookCheckmarkContainer.addSubview(bookCheckmark)
    bookCheckmarkContainer.addSubview(bookCheckmarkBorder)
    
    contentView.addSubview(propContainer)
    contentView.addSubview(bookImage)
    contentView.addSubview(bookTitle)
    contentView.addSubview(activityIndicator)
    contentView.addSubview(bookOverlay)
    contentView.addSubview(bookCheckmarkContainer)
    
    propContainer.topAnchor.constraint(equalTo: propContainer.superview!.topAnchor, constant: 10).isActive = true
    propContainer.leadingAnchor.constraint(equalTo: propContainer.superview!.leadingAnchor, constant: 20).isActive = true
    propContainer.trailingAnchor.constraint(equalTo: propContainer.superview!.trailingAnchor, constant: -20).isActive = true
    propContainer.bottomAnchor.constraint(equalTo: bookImage.topAnchor, constant: -10).isActive = true
    
    bookImage.centerXAnchor.constraint(equalTo: bookImage.superview!.centerXAnchor).isActive = true
    bookImage.centerYAnchor.constraint(equalTo: bookImage.superview!.centerYAnchor).isActive = true
    
    bookTitle.topAnchor.constraint(equalTo: bookImage.bottomAnchor, constant: 10).isActive = true
    bookTitle.leadingAnchor.constraint(equalTo: bookTitle.superview!.leadingAnchor, constant: 10).isActive = true
    bookTitle.trailingAnchor.constraint(equalTo: bookTitle.superview!.trailingAnchor, constant: -10).isActive = true
    bookTitle.bottomAnchor.constraint(equalTo: bookTitle.superview!.bottomAnchor, constant: -10).isActive = true
    
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
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    layer.borderColor = UIColor(named: "background")?.cgColor
  }
  
  func loadImage(image: String?, imageSize: CGFloat) {
    if let image = image {
      bookImage.isHidden = true
      activityIndicator.startAnimating()
      bookImage.load(url: URL(string: image)!) { _ in
        self.activityIndicator.stopAnimating()
        self.bookImage.image = self.bookImage.image!.resize(imageSize)
        self.bookImage.isHidden = false
      }
    } else {
      bookImage.image = UIImage(named: "no_cover_thumb")!.resize(imageSize)
    }
  }
  
}
