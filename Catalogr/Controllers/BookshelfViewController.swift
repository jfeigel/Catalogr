//
//  BookshelfViewController.swift
//  Catalogr
//
//  Created by jfeigel on 4/14/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

private let reuseIdentifier = "BookshelfCell"

class BookshelfViewController: UICollectionViewController {
  
  var bookshelfContainerViewController: BookshelfContainerViewController!
  var bookshelf: [SavedBook]?
  var deleteButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    deleteButton.isEnabled = isEditing
  }
  
  override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count == 0 {
      deleteButton.isEnabled = false
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
  
// MARK: UICollectionViewDataSource

extension BookshelfViewController {

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return bookshelf?.count ?? 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookshelfCollectionViewCell
    
    if bookshelf != nil {
      let book = bookshelf![indexPath.row].book
      if let imageLinks = book.volumeInfo.imageLinks {
        cell.bookImage.load(url: URL(string: imageLinks.thumbnail)!, completion: nil)
      } else {
        cell.bookImage.image = UIImage(named: "no_cover_thumb")
      }
    } else {
      cell.bookImage.image = UIImage(named: "no_cover_thumb")
    }
    
    cell.bookCheckmark.roundCorners(corners: [.topLeft, .topRight, .bottomRight, .bottomLeft], radius: cell.bookCheckmark.frame.size.width)
    
    cell.isInEditingMode = false
        
    return cell
  }
  
}
