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
  
  var bookshelfContainerViewController: BookshelfContainerViewController!
  var bookshelf = [SavedBook]() {
    didSet {
      var numberOfPages = Int(bookshelf.count / itemsPerPage)
      if bookshelf.count % itemsPerPage > 0 {
        numberOfPages += 1
      }
      pageControl.numberOfPages = numberOfPages
    }
  }
  var deleteButton: UIBarButtonItem!
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .systemBackground
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.isScrollEnabled = true
    cv.isPagingEnabled = true
    cv.showsHorizontalScrollIndicator = false
    cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    cv.register(BookshelfCollectionViewCell.self, forCellWithReuseIdentifier: "BookshelfCell")
    return cv
  }()
  
  let pageControl: UIPageControl = {
    let pageControl = UIPageControl(frame: .zero)
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    return pageControl
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    
    deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAction(_:)))
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    collectionView.allowsMultipleSelection = editing
    let indexPaths = collectionView.indexPathsForVisibleItems
    for indexPath in indexPaths {
      let cell = collectionView.cellForItem(at: indexPath) as! BookshelfCollectionViewCell
      cell.isInEditingMode = (indexPath.section * itemsPerPage) + indexPath.row < bookshelf.count && editing
    }
  }
  
  @objc func deleteAction(_ sender: UIBarButtonItem) {
    if let selectedCells = collectionView.indexPathsForSelectedItems {
      let items = selectedCells.map { ($0.section * itemsPerPage) + $0.row }.sorted().reversed()
      
      for item in items {
        bookshelf.remove(at: item)
      }

      collectionView.reloadData()
      deleteButton.isEnabled = false
      bookshelfContainerViewController.setEditing(false, animated: true)
    }
  }
  
  func addBook(_ book: SavedBook) {
    let index = bookshelf.count
    let section = Int(index / itemsPerPage)
    let row = Int(index % itemsPerPage)
    bookshelf.append(book)
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
    return (indexPath.section * itemsPerPage) + indexPath.row < bookshelf.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if !isEditing {
      let index = (indexPath.section * itemsPerPage) + indexPath.row
      bookshelfContainerViewController.performSegue(withIdentifier: "bookDetail", sender: bookshelf[index])
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
    (cell as! BookshelfCollectionViewCell).isInEditingMode = (indexPath.section * itemsPerPage) + indexPath.row < bookshelf.count && isEditing
  }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension BookshelfCollectionViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let fItemsPerRow = CGFloat(itemsPerRow)
    let fItemsPerCol = CGFloat(itemsPerCol)
    let rowBordersWidth: CGFloat = (fItemsPerRow - 1) * 10
    let colBordersWidth: CGFloat = ((fItemsPerCol - 1) * 10) + 20
    return CGSize(
      width: (collectionView.frame.width - rowBordersWidth) / fItemsPerRow,
      height: (collectionView.frame.height - colBordersWidth) / fItemsPerCol
    )
  }
  
}
  
// MARK: - UICollectionViewDataSource

extension BookshelfCollectionViewController: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    var numOfSecs = Int(bookshelf.count / itemsPerPage)
    if bookshelf.count % itemsPerPage > 0 {
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
    
    if index < bookshelf.count {
      let book = bookshelf[index].book
      
      if let imageLinks = book.volumeInfo.imageLinks, let thumbnail = imageLinks.thumbnail {
        cell.activityIndicator.startAnimating()
        cell.bookImage.load(url: URL(string: thumbnail)!) { _ in
          cell.activityIndicator.stopAnimating()
          cell.bookImage.image = cell.bookImage.image!.resize(183)
          cell.bookImage.dropShadow(type: .oval)
          cell.bookImage.isHidden = false
        }
      } else {
        cell.bookImage.image = UIImage(named: "no_cover_thumb")!.resize(183)
        DispatchQueue.main.async {
          cell.bookImage.dropShadow(type: .oval)
          cell.bookImage.isHidden = false
        }
      }
      
      cell.isInEditingMode = isEditing
    } else {
      cell.isEmpty = true
    }
        
    return cell
  }
  
}
