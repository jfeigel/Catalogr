//
//  BookshelfCollectionViewController.swift
//  Catalogr
//
//  Created by jfeigel on 4/14/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class BookshelfCollectionViewController: UIViewController {
  
  private var itemsPerPage: Int = 9
  private var itemsPerRow: Int = 3
  private var itemsPerCol: Int = 3
  
  weak var bookshelfContainerViewController: BookshelfContainerViewController!
  var deleteButton: UIBarButtonItem!
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = UIColor(named: "secondaryBackground")
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.isScrollEnabled = true
    cv.isPagingEnabled = true
    cv.showsHorizontalScrollIndicator = false
    cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    cv.register(BookshelfCollectionViewCell.self, forCellWithReuseIdentifier: "BookshelfCell")
    cv.register(BookshelfCollectionViewCellEmpty.self, forCellWithReuseIdentifier: "BookshelfCellEmpty")
    
    return cv
  }()
  
  let pageControl: UIPageControl = {
    let pageControl = UIPageControl(frame: .zero)
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    pageControl.pageIndicatorTintColor = .systemGray4
    pageControl.currentPageIndicatorTintColor = .systemGray
    return pageControl
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setPageControl()
    
    view.addSubview(collectionView)
    view.addSubview(pageControl)
    
    collectionView.delegate = self
    collectionView.dataSource = self
    
    pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
    pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
    
    collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: 0).isActive = true
    
    deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteConfirmation(_:)))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    collectionView.reloadData()
    setPageControl()
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    collectionView.allowsMultipleSelection = editing
    let indexPaths = collectionView.indexPathsForVisibleItems
    for indexPath in indexPaths {
      if (indexPath.section * itemsPerPage) + indexPath.row < Bookshelf.shared.books.count {
        (collectionView.cellForItem(at: indexPath) as! BookshelfCollectionViewCell).isInEditingMode = editing
      }
    }
  }
  
  func setPageControl() {
    var numberOfPages = Int(Bookshelf.shared.books.count / itemsPerPage)
    if Bookshelf.shared.books.count % itemsPerPage > 0 {
      numberOfPages += 1
    }
    pageControl.numberOfPages = numberOfPages
  }
  
  @objc func deleteConfirmation(_ sender: UIBarButtonItem) {
    if let selectedCellsCount = collectionView.indexPathsForSelectedItems?.count {
      deleteConfirmationAction(title: "Delete \(selectedCellsCount) book\(selectedCellsCount > 1 ? "s" : "")?", index: nil)
    }
  }
  
  private func deleteConfirmationAction(title: String, index: Int?) {
    let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { action in self.deleteAction(action, index: index)}))
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    self.present(actionSheet, animated: true, completion: nil)
  }
  
  private func deleteAction(_ action: UIAlertAction, index: Int?) {
    if let selectedCells = collectionView.indexPathsForSelectedItems, isEditing == true {
      let items = selectedCells.map { ($0.section * itemsPerPage) + $0.row }.sorted().reversed()
        
      for item in items {
        Bookshelf.shared.books.remove(at: item)
      }
    } else if let index = index {
      Bookshelf.shared.books.remove(at: index)
    }
    
    setPageControl()
    collectionView.reloadData()
    deleteButton.isEnabled = false
    bookshelfContainerViewController.setEditing(false, animated: true)
  }
  
  func addBook(_ book: SavedBook) {
    let index = Bookshelf.shared.books.count
    let section = Int(index / itemsPerPage)
    let row = Int(index % itemsPerPage)
    Bookshelf.shared.books.append(book)
    setPageControl()
    if index % itemsPerPage != 0 {
      collectionView.reloadItems(at: [IndexPath(row: row, section: section)])
    } else {
      let sectionIndex = IndexSet(integer: section)
      collectionView.insertSections(sectionIndex)
      collectionView.reloadSections(sectionIndex)
    }
  }
  
}

// MARK: - UICollectionViewDelegate

extension BookshelfCollectionViewController: UICollectionViewDelegate {
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return (indexPath.section * itemsPerPage) + indexPath.row < Bookshelf.shared.books.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if !isEditing {
      let index = (indexPath.section * itemsPerPage) + indexPath.row
      bookshelfContainerViewController.performSegue(withIdentifier: "bookDetail", sender: Bookshelf.shared.books[index])
    } else if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count > 0 {
      deleteButton.isEnabled = true
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count == 0 {
      deleteButton.isEnabled = false
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if (indexPath.section * itemsPerPage) + indexPath.row < Bookshelf.shared.books.count {
      (cell as! BookshelfCollectionViewCell).isInEditingMode = isEditing
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
    let index = (indexPath.section * itemsPerPage) + indexPath.row
    if index >= Bookshelf.shared.books.count { return nil }
    let book = Bookshelf.shared.books[index].book
    let identifier = "\(index)" as NSString
    
    return UIContextMenuConfiguration(
      identifier: identifier,
      previewProvider: nil
    ) { _ in
      let deleteBookAction = UIAction(
        title: "Delete Book",
        image: UIImage(systemName: "delete.left"),
        identifier: nil,
        attributes: UIMenuElement.Attributes.destructive
      ) { _ in
        self.deleteConfirmationAction(title: "Delete \(book.volumeInfo.title)?", index: index)
      }
      
      return UIMenu(title: "", children: [deleteBookAction])
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    return makeTargetedPreview(for: configuration)
  }
  
  func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    return makeTargetedPreview(for: configuration)
  }
  
  private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    guard
      let identifier = configuration.identifier as? String,
      let index = Int(identifier),
      index < Bookshelf.shared.books.count,
      let cell = collectionView.cellForItem(at: IndexPath(row: Int(index % itemsPerPage), section: Int(index / itemsPerPage))) as? BookshelfCollectionViewCell
      else {
        return nil
    }
    
    let parameters = UIPreviewParameters()
    parameters.backgroundColor = .clear
    
    return UITargetedPreview(view: cell.bookImage, parameters: parameters)
  }
  
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BookshelfCollectionViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let fItemsPerRow = CGFloat(itemsPerRow)
    let fItemsPerCol = CGFloat(itemsPerCol)
    return CGSize(
      width: collectionView.frame.width / fItemsPerRow,
      height: collectionView.frame.height / fItemsPerCol
    )
  }
  
}

// MARK: - UICollectionViewDataSource

extension BookshelfCollectionViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    var numOfSecs = Int(Bookshelf.shared.books.count / itemsPerPage)
    if Bookshelf.shared.books.count % itemsPerPage > 0 {
      numOfSecs += 1
    }
    return numOfSecs
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return itemsPerPage
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let index = (indexPath.section * itemsPerPage) + indexPath.row
        
    if index < Bookshelf.shared.books.count {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookshelfCell", for: indexPath) as! BookshelfCollectionViewCell
      let imageSize = cell.contentView.frame.height * 0.5
      let book = Bookshelf.shared.books[index].book
      
      var thumbnail: String?
      
      if let imageLinks = book.volumeInfo.imageLinks {
        thumbnail = imageLinks.thumbnail
      }
      
      cell.loadImage(image: thumbnail, imageSize: imageSize)
      
      Bookshelf.shared.books[index].read = Bool.random()
      Bookshelf.shared.books[index].borrowed = Bool.random()
      Bookshelf.shared.books[index].rating = Int.random(in: 0 ... 5)

      cell.readIcon.tintColor = Bookshelf.shared.books[index].read ? nil : .systemGray2
      cell.borrowedIcon.isHighlighted = Bookshelf.shared.books[index].borrowed
      cell.borrowedIcon.tintColor = Bookshelf.shared.books[index].borrowed ? nil : .systemGray2
      cell.ratingValue.text = Bookshelf.shared.books[index].rating == 0 ? "-" : "\(Bookshelf.shared.books[index].rating)"
      cell.ratingValue.textColor = Bookshelf.shared.books[index].rating == 0 ? .systemGray2 : .systemBlue
      cell.ratingStar.isHighlighted = Bookshelf.shared.books[index].rating != 0
      cell.ratingStar.tintColor = Bookshelf.shared.books[index].rating == 0 ? .systemGray2 : nil
      cell.bookTitle.text = book.volumeInfo.title
      cell.isInEditingMode = isEditing
      
      return cell
    } else {
      return collectionView.dequeueReusableCell(withReuseIdentifier: "BookshelfCellEmpty", for: indexPath) as! BookshelfCollectionViewCellEmpty
    }
  }
  
}
