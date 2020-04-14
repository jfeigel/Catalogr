//
//  BookshelfViewController.swift
//  Catalogr
//
//  Created by jfeigel on 3/25/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation
import UIKit

import BarcodeScanner

class BookshelfViewController: UIViewController {
  private let bsViewController: BarcodeScannerViewController = BarcodeScannerViewController()
  
  @IBOutlet var downArrow: UIImageView!

  @IBAction func handleScannerPresent(_ sender: UIBarButtonItem) {
    present(bsViewController, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bsViewController.codeDelegate = self
    bsViewController.errorDelegate = self
    bsViewController.dismissalDelegate = self
    bsViewController.headerViewController.titleLabel.textColor = UIColor.label
    bsViewController.headerViewController.closeButton.tintColor = UIColor.systemBlue
    
    var downArrowFrame = self.downArrow.frame
    downArrowFrame.origin = CGPoint(x: downArrowFrame.origin.x, y: downArrowFrame.origin.y + 10.0)
    UIView.animate(withDuration: 0.5, delay: 0.5, options: [.repeat, .autoreverse], animations: { self.downArrow.frame = downArrowFrame }, completion: nil)

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "addBook", let destVC = segue.destination as? AddBookViewController {
      destVC.book = sender as? Book
    }
  }
}

// MARK: - BarcodeScannerCodeDelegate

extension BookshelfViewController: BarcodeScannerCodeDelegate {
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

extension BookshelfViewController: BarcodeScannerErrorDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
    print(error)
  }
}

// MARK: - BarcodeScannerDismissalDelegate

extension BookshelfViewController: BarcodeScannerDismissalDelegate {
  func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
    controller.reset(animated: false)
    controller.dismiss(animated: true, completion: nil)
  }
}
