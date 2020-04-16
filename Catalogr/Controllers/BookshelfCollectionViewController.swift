//
//  BookshelfCollectionViewController.swift
//  Catalogr
//
//  Created by jfeigel on 4/14/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class BookshelfCollectionViewController: UIViewController {
  
  var bookshelfContainerViewController: BookshelfContainerViewController!
  var bookshelf: [SavedBook]?
  var deleteButton: UIBarButtonItem!
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .systemBackground
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.isScrollEnabled = true
    cv.isPagingEnabled = true
    cv.register(BookshelfCollectionViewCell.self, forCellWithReuseIdentifier: "BookshelfCell")
    return cv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(collectionView)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    
    deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAction(_:)))
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    collectionView.allowsMultipleSelection = editing
    let indexPaths = collectionView.indexPathsForVisibleItems
    for indexPath in indexPaths {
      let cell = collectionView.cellForItem(at: indexPath) as! BookshelfCollectionViewCell
      cell.isInEditingMode = editing
    }
  }
  
  @objc func deleteAction(_ sender: UIBarButtonItem) {
    if let selectedCells = collectionView.indexPathsForSelectedItems {
      let items = selectedCells.map { $0.item }.sorted().reversed()
      
      for item in items {
        bookshelf!.remove(at: item)
      }
      
      collectionView.deleteItems(at: selectedCells)
      deleteButton.isEnabled = false
      bookshelfContainerViewController.setEditing(false, animated: true)
    }
  }
  
  func addBook(_ book: SavedBook) {
    bookshelf!.append(book)
    let index = collectionView.indexPathsForVisibleItems.count
    collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
  }
  
}

// MARK: - UICollectionViewDelegate

extension BookshelfCollectionViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    deleteButton.isEnabled = isEditing
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count == 0 {
      deleteButton.isEnabled = false
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    (cell as! BookshelfCollectionViewCell).isInEditingMode = isEditing
  }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension BookshelfCollectionViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (collectionView.frame.width - 10) / 2, height: (collectionView.frame.height - 180) / 3)
  }
  
}
  
// MARK: - UICollectionViewDataSource

extension BookshelfCollectionViewController: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return bookshelf?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookshelfCell", for: indexPath) as! BookshelfCollectionViewCell
    
    if bookshelf != nil {
      let book = bookshelf![indexPath.row].book
      if let imageLinks = book.volumeInfo.imageLinks {
        cell.bookImage.load(url: URL(string: imageLinks.thumbnail)!, completion: nil)
      }
    }
    
    cell.isInEditingMode = isEditing
        
    return cell
  }
  
}
