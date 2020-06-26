//
//  BookshelfContainerViewController.swift
//  Catalogr
//
//  Created by jfeigel on 3/25/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation
import UIKit
import os.log

class BookshelfContainerViewController: UIViewController {
  
  var isBookshelfLoaded: Bool = false
  var isLoading: Bool = false {
    didSet {
      if isLoading == true {
        activityIndicatorContainer.isHidden = false
        UIView.animate(withDuration: 0.3, animations: { self.activityIndicatorContainer.alpha = 0.9 }, completion: nil)
      } else {
        UIView.animate(withDuration: 0.3, animations: { self.activityIndicatorContainer.alpha = 0.0 }, completion: { _ in self.activityIndicatorContainer.isHidden = true })
      }
    }
  }
  
  var bookshelfCollectionViewController: BookshelfCollectionViewController!
  var scanBarcodeButton: UIBarButtonItem!
  
  @IBOutlet var activityIndicatorContainer: UIView!
  @IBOutlet var emptyView: UIView!
  @IBOutlet var nonEmptyView: UIView!
  @IBOutlet var downArrow: UIImageView!
 
  @IBAction func unwindToBookshelf(segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "addBookUnwindToBookshelf":
      if let source = segue.source as? AddBookViewController, let bookData = source.book {
        let newBook = SavedBook(book: bookData)
        Bookshelf.shared.addBook(newBook)
        setVisibleViews()
      }
    case "scannerViewUnwindToBookshelf":
      if let source = segue.source as? ISBNScannerViewController {
        GAPI.shared.getBooks(searchText: source.foundNumber, type: .isbn) { (books, message)  in
          if books != nil {
            self.performSegue(withIdentifier: "addBook", sender: books![0])
          }
        }
      }
    case "cancelAddBookUnwindToBookshelf": break
    default:
      fatalError("Error: Unknown Segue Identifier: \"\(segue.identifier ?? "")\"")
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scanBarcodeButton = UIBarButtonItem(image: UIImage(systemName: "barcode.viewfinder"), style: .plain, target: self, action: #selector(handleScannerPresent(_:)))
    navigationItem.rightBarButtonItem = scanBarcodeButton
    
    loadBookshelf(initial: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    setEditing(false, animated: false)
    super.viewWillDisappear(animated)
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    if editing {
      bookshelfCollectionViewController.deleteButton.isEnabled = false
      navigationItem.rightBarButtonItem = bookshelfCollectionViewController.deleteButton
    } else {
      navigationItem.rightBarButtonItem = scanBarcodeButton
      if isBookshelfLoaded == true {
        setVisibleViews()
      }
    }
    
    bookshelfCollectionViewController?.setEditing(editing, animated: animated)
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "bookshelf" {
      return Bookshelf.shared.books != nil && Bookshelf.shared.books.count >= 0
    }
    
    return true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "bookDetail":
      if let destVC = segue.destination as? BookDetailViewController {
        destVC.book = sender as? SavedBook
        destVC.navigationItem.title = destVC.book.book.volumeInfo.title
      }
    case "bookshelf":
      if let destVC = segue.destination as? BookshelfCollectionViewController {
        bookshelfCollectionViewController = destVC
        destVC.bookshelfContainerViewController = self
      }
    default:
      os_log("Unknown Segue Identifier found", log: OSLog.default, type: .error)
    }
  }

  @objc func handleScannerPresent(_ sender: UIBarButtonItem) {
    present(TabBarController.barcodeScannerViewController, animated: true, completion: nil)
  }
  
  func loadBookshelf(initial: Bool = false) {
    isLoading = true
    
    Bookshelf.shared.loadBookshelf() { err in
      guard err == nil else {
        Toast.shared.show(err!, inView: self.nonEmptyView, backgroundColor: .red)
        return
      }
      
      DispatchQueue.main.async {
        self.isLoading = false
        if self.isBookshelfLoaded == false {
          self.performSegue(withIdentifier: "bookshelf", sender: nil)
        } else {
          self.bookshelfCollectionViewController.collectionView.reloadData()
          self.bookshelfCollectionViewController.setPageControl()
        }
        self.isBookshelfLoaded = true
        self.setVisibleViews(initial: initial)
        if initial == false { Toast.shared.show("Refreshed bookshelf from iCloud", inView: self.nonEmptyView) }
      }
    }
  }
  
  private func setVisibleViews(initial: Bool = false) {
    self.downArrow.layer.removeAllAnimations()

    if initial == true {
      emptyView.alpha = 0.0
      nonEmptyView.alpha = 0.0
    }

    if Bookshelf.shared.books.count == 0 {
      emptyView.isHidden = false
      nonEmptyView.isHidden = true
      navigationItem.leftBarButtonItem = nil
      self.animateDownArrow()
      UIView.animate(withDuration: 0.3) {
        self.emptyView.alpha = 1.0
      }
    } else {
      emptyView.isHidden = true
      nonEmptyView.isHidden = false
      navigationItem.leftBarButtonItem = editButtonItem
      UIView.animate(withDuration: 0.3) {
        self.nonEmptyView.alpha = 1.0
      }
    }
  }
  
  private func animateDownArrow() {
    let downArrowX: CGFloat = downArrow.frame.origin.x
    let downArrowY: CGFloat = downArrow.frame.origin.y
    let downArrowWidth: CGFloat = downArrow.frame.size.width
    let downArrowHeight: CGFloat = downArrow.frame.size.height
    
    downArrow.frame = CGRect(x: downArrowX, y: downArrowY, width: downArrowWidth, height: downArrowHeight)
    UIView.animate(withDuration: 0.5, delay: 0.5, options: [.repeat, .autoreverse], animations: { self.downArrow.frame = CGRect(x: downArrowX, y: downArrowY + 10.0, width: downArrowWidth, height: downArrowHeight) }, completion: nil)
  }

}
