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

import BarcodeScanner

class BookshelfContainerViewController: UIViewController {
  private let bsViewController = BarcodeScannerViewController()
  
  var bookshelf: [SavedBook]!
  var bookshelfViewController: BookshelfViewController!
  var scanBarcodeButton: UIBarButtonItem!
  
  var downArrowX: CGFloat!
  var downArrowY: CGFloat!
  var downArrowWidth: CGFloat!
  var downArrowHeight: CGFloat!
  
  @IBOutlet var emptyView: UIView!
  @IBOutlet var nonEmptyView: UIView!
  @IBOutlet var downArrow: UIImageView!
 
  @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
    if segue.identifier == "addBookReturn", let source = segue.source as? AddBookViewController {
      if let bookData = source.book {
        let newBook = SavedBook(book: bookData)
        bookshelf.append(newBook)
        bookshelfViewController.addBook(newBook)
        saveBookshelf()
        setVisibleViews()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scanBarcodeButton = UIBarButtonItem(image: UIImage(systemName: "barcode.viewfinder"), style: .plain, target: self, action: #selector(handleScannerPresent(_:)))
    navigationItem.rightBarButtonItem = scanBarcodeButton
    
    downArrowX = downArrow.frame.origin.x
    downArrowY = downArrow.frame.origin.y
    downArrowWidth = downArrow.frame.size.width
    downArrowHeight = downArrow.frame.size.height
    
    bookshelf = loadBookshelf()
    setVisibleViews(initial: true)
    
    bsViewController.codeDelegate = self
    bsViewController.errorDelegate = self
    bsViewController.dismissalDelegate = self
    bsViewController.headerViewController.titleLabel.textColor = UIColor.label
    bsViewController.headerViewController.closeButton.tintColor = UIColor.systemBlue
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    if editing {
      bookshelfViewController.deleteButton.isEnabled = false
      navigationItem.rightBarButtonItem = bookshelfViewController.deleteButton
    } else {
      navigationItem.rightBarButtonItem = scanBarcodeButton
      bookshelf = bookshelfViewController.bookshelf
      saveBookshelf()
      setVisibleViews()
    }
    
    bookshelfViewController.setEditing(editing, animated: animated)
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "bookshelf" {
      if bookshelf != nil {
        return (bookshelf.count >= 0)
      } else {
        return false
      }
    }
    
    return true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "addBook":
      if let destVC = segue.destination as? AddBookViewController {
        destVC.book = sender as? Book
      }
    case "bookshelf":
      if let destVC = segue.destination as? BookshelfViewController {
        bookshelfViewController = destVC
        destVC.bookshelf = self.bookshelf
        destVC.bookshelfContainerViewController = self
      }
    default:
      os_log("Unknown Segue Identifier found", log: OSLog.default, type: .error)
    }
  }

  @objc func handleScannerPresent(_ sender: UIBarButtonItem) {
    present(bsViewController, animated: true, completion: nil)
  }
  
  private func setVisibleViews(initial: Bool = false) {
    if initial {
      performSegue(withIdentifier: "bookshelf", sender: nil)
    }
    
    self.downArrow.layer.removeAllAnimations()
    
    if bookshelf.count == 0 {
      emptyView.alpha = 1.0
      nonEmptyView.alpha = 0.0
      navigationItem.leftBarButtonItem = nil
      animateDownArrow()
    } else {
      emptyView.alpha = 0.0
      nonEmptyView.alpha = 1.0
      navigationItem.leftBarButtonItem = editButtonItem
    }
  }
  
  private func animateDownArrow() {
    downArrow.frame = CGRect(x: downArrowX, y: downArrowY, width: downArrowWidth, height: downArrowHeight)
    UIView.animate(withDuration: 0.5, delay: 0.5, options: [.repeat, .autoreverse], animations: { self.downArrow.frame = CGRect(x: self.downArrowX, y: self.downArrowY + 10.0, width: self.downArrowWidth, height: self.downArrowHeight) }, completion: nil)
  }
  
  private func loadBookshelf() -> [SavedBook]  {
    var bookshelf: [SavedBook]
    let decoder = JSONDecoder()
    
    do {
      let data = try Data(contentsOf: Bookshelf.ArchiveURL)
      bookshelf = try decoder.decode([SavedBook].self, from: data)
    } catch {
      bookshelf = [SavedBook]()
      os_log("Failed to load Bookshelf", log: OSLog.default, type: .error)
    }
    
    return bookshelf
  }
  
  private func saveBookshelf() {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(bookshelf)
      try data.write(to: Bookshelf.ArchiveURL)
    } catch {
      os_log("Failed to save Bookshelf", log: OSLog.default, type: .error)
    }
  }

}

// MARK: - BarcodeScannerCodeDelegate

extension BookshelfContainerViewController: BarcodeScannerCodeDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
    getBook(controller: controller, code: code) { (bookData) in
      controller.reset(animated: false)
      controller.dismiss(animated: true, completion: {
        self.performSegue(withIdentifier: "addBook", sender: bookData)
      })
    }
  }
  
  func getBook(controller: BarcodeScannerViewController, code: String, completion: @escaping (Book) -> ()) {
    let urlString = GAPI.getByIsbnURL(code)
    if let url = URL(string: urlString) {
      URLSession.shared.dataTask(with: url) { data, res, err in
        guard err == nil else {
          DispatchQueue.main.async {
            controller.resetWithError(message: "Error getting book data")
          }
          print(err!)
          return
        }
        
        guard let resData = data else {
          DispatchQueue.main.async {
            controller.resetWithError(message: "Error: did not receive data")
          }
          return
        }
        
        if var books = try? JSONDecoder().decode(BooksResponse.self, from: resData) {
          if books.totalItems > 0 {
            if let thumbnail = books.items![0].volumeInfo.imageLinks?.thumbnail {
              books.items![0].volumeInfo.imageLinks!.thumbnail = thumbnail.replacingOccurrences(of: #"^http\:"#, with: "https:", options: .regularExpression)
            }
            DispatchQueue.main.async {
              completion(books.items![0])
            }
          } else {
            DispatchQueue.main.async {
              controller.resetWithError(message: "Error: No books found")
            }
            return
          }
        } else {
          DispatchQueue.main.async {
            controller.resetWithError(message: "Error: Cannot convert data to JSON")
          }
          return
        }
      }.resume()
    }
  }
}

// MARK: - BarcodeScannerErrorDelegate

extension BookshelfContainerViewController: BarcodeScannerErrorDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
    print(error)
  }
}

// MARK: - BarcodeScannerDismissalDelegate

extension BookshelfContainerViewController: BarcodeScannerDismissalDelegate {
  func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
    controller.reset(animated: false)
    controller.dismiss(animated: true, completion: nil)
  }
}
