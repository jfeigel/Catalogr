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
  var books: [SavedBook]! {
    didSet {
      var numberOfPages = Int(books.count / itemsPerPage)
      if books.count % itemsPerPage > 0 {
        numberOfPages += 1
      }
      pageControl.numberOfPages = numberOfPages
    }
  }
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
    
    books = SceneDelegate.shared!.bookshelf.books
    
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
    if isViewLoaded {
      books = SceneDelegate.shared!.bookshelf.books
      collectionView.reloadData()
    }
    
    super.viewWillAppear(animated)
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    collectionView.allowsMultipleSelection = editing
    let indexPaths = collectionView.indexPathsForVisibleItems
    for indexPath in indexPaths {
      let cell = collectionView.cellForItem(at: indexPath) as! BookshelfCollectionViewCell
      cell.isInEditingMode = (indexPath.section * itemsPerPage) + indexPath.row < books.count && editing
    }
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
        books.remove(at: item)
      }
    } else if let index = index {
      books.remove(at: index)
    }
    
    collectionView.reloadData()
    deleteButton.isEnabled = false
    bookshelfContainerViewController.setEditing(false, animated: true)
  }
  
  func addBook(_ book: SavedBook) {
    let index = books.count
    let section = Int(index / itemsPerPage)
    let row = Int(index % itemsPerPage)
    books.append(book)
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
    return (indexPath.section * itemsPerPage) + indexPath.row < books.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if !isEditing {
      let index = (indexPath.section * itemsPerPage) + indexPath.row
      bookshelfContainerViewController.performSegue(withIdentifier: "bookDetail", sender: books[index])
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
    (cell as! BookshelfCollectionViewCell).isInEditingMode = (indexPath.section * itemsPerPage) + indexPath.row < books.count && isEditing
  }
  
  func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
    let index = (indexPath.section * itemsPerPage) + indexPath.row
    if index >= books.count { return nil }
    let book = books[index].book
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
    print(configuration.identifier)
    guard
      let identifier = configuration.identifier as? String,
      let index = Int(identifier),
      let cell = collectionView.cellForItem(at: IndexPath(row: Int(index / itemsPerPage), section: Int(index % itemsPerPage))) as? BookshelfCollectionViewCell
      else {
        return nil
    }
    
    return UITargetedPreview(view: cell.bookImage)
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
    var numOfSecs = Int(books.count / itemsPerPage)
    if books.count % itemsPerPage > 0 {
      numOfSecs += 1
    }
    return numOfSecs
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return itemsPerPage
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookshelfCell", for: indexPath) as! BookshelfCollectionViewCell
    let index = (indexPath.section * itemsPerPage) + indexPath.row
    let imageSize = cell.contentView.frame.height * 0.5
    
    if index < books.count {
      let book = books[index].book
      
      if let imageLinks = book.volumeInfo.imageLinks, let thumbnail = imageLinks.thumbnail {
        cell.activityIndicator.startAnimating()
        cell.bookImage.load(url: URL(string: thumbnail)!) { _ in
          cell.activityIndicator.stopAnimating()
          cell.bookImage.image = cell.bookImage.image!.resize(imageSize)
          cell.bookImage.isHidden = false
        }
      } else {
        cell.bookImage.image = UIImage(named: "no_cover_thumb")!.resize(imageSize)
        DispatchQueue.main.async {
          cell.bookImage.isHidden = false
        }
      }
      
      books[index].read = Bool.random()
      books[index].borrowed = Bool.random()
      books[index].rating = Int.random(in: 0 ... 5)

      cell.readIcon.tintColor = books[index].read ? nil : .systemGray2
      cell.borrowedIcon.isHighlighted = books[index].borrowed
      cell.borrowedIcon.tintColor = books[index].borrowed ? nil : .systemGray2
      cell.ratingValue.text = books[index].rating == 0 ? "-" : "\(books[index].rating)"
      cell.ratingValue.textColor = books[index].rating == 0 ? .systemGray2 : .systemBlue
      cell.ratingStar.isHighlighted = books[index].rating != 0
      cell.ratingStar.tintColor = books[index].rating == 0 ? .systemGray2 : nil
      cell.bookTitle.text = book.volumeInfo.title
      cell.isInEditingMode = isEditing
    } else {
      cell.isEmpty = true
    }
    
    return cell
  }
  
}
