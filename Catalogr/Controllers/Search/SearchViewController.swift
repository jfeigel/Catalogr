//
//  SearchViewController.swift
//  Catalogr
//
//  Created by jfeigel on 4/9/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit
import os.log

class SearchViewController: UIViewController {
  
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var messageLabel: UILabel!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  @IBOutlet var tableView: UITableView!
  
  private let defaultMessageLabel = "Enter text above to search for a book"
  
  var results: [Book] = [] {
    didSet {
      tableView.isHidden = results.count == 0
      messageLabel.isHidden = results.count > 0
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    searchBar.delegate = self
    searchBar.searchTextField.delegate = self
    messageLabel.text = defaultMessageLabel
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(endIfEditing(_:)))
    tap.delegate = self
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func endIfEditing(_ sender: UITapGestureRecognizer) {
    if sender.state == .ended, searchBar.isFirstResponder {
      searchBarCancelButtonClicked(searchBar)
    }
  }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
    
    cell.book = results[indexPath.row]
    
    return cell
  }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedBook = results[indexPath.row]
    
    if let viewController = storyboard?.instantiateViewController(identifier: "AddBookViewController") as? AddBookViewController {
      viewController.book = selectedBook
      viewController.selectedIndex = 1
      viewController.isModalInPresentation = true
      present(viewController, animated: true, completion: nil)
    }
  }
  
  func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
    let result = results[indexPath.row]
    let identifier = "\(indexPath.row)" as NSString
    
    return UIContextMenuConfiguration(
      identifier: identifier,
      previewProvider: nil
    ) { _ in
      let addToBookshelfAction = UIAction(
        title: "Add to Bookshelf",
        image: UIImage(systemName: "book"),
        identifier: nil
      ) { _ in
        let newBook = SavedBook(book: result)
        Bookshelf.shared.addBook(newBook)
      }
      
      let addToWishlistAction = UIAction(
        title: "Add to Wishlist",
        image: UIImage(systemName: "heart"),
        identifier: nil
      ) { _ in
        let newBook = SavedBook(book: result)
        Bookshelf.shared.addBook(newBook)
      }
      
      return UIMenu(title: "", children: [addToBookshelfAction, addToWishlistAction])
    }
  }
  
  func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    return makeTargetedPreview(for: configuration)
  }
  
  func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    return makeTargetedPreview(for: configuration)
  }
  
  private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    guard
      let identifier = configuration.identifier as? String,
      let index = Int(identifier),
      let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchTableViewCell
    else {
      return nil
    }
    
    let parameters = UIPreviewParameters()
    parameters.backgroundColor = .clear
    
    return UITargetedPreview(view: cell.bookImage, parameters: parameters)
  }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
    searchBar.showsScopeBar = true
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    searchBar.showsScopeBar = false
    searchBar.text = nil
    messageLabel.text = defaultMessageLabel
    results = []
    tableView.reloadData()
    searchBar.resignFirstResponder()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchBar.showsCancelButton = false
    searchBar.showsScopeBar = false
    var queryType: QueryType!
    switch searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex].lowercased() {
    case "title": queryType = .title
    case "author": queryType = .author
    default: break
    }
    let searchText = searchBar.text!
    if searchText.isEmpty {
      messageLabel.text = defaultMessageLabel
      results = []
      tableView.reloadData()
    } else {
      messageLabel.isHidden = true
      activityIndicator.startAnimating()
      tableView.isUserInteractionEnabled = false
      tableView.alpha = 0.3
      GAPI.getBooks(searchText: searchText, type: queryType) { (books, message) in
        self.results = books ?? []
        self.messageLabel.text = message
        self.messageLabel.isHidden = message != nil
        self.messageLabel.textColor = message?.lowercased().contains("error") ?? false ? .systemRed : .label
        self.activityIndicator.stopAnimating()
        self.tableView.isUserInteractionEnabled = true
        self.tableView.alpha = 1.0
        self.tableView.reloadData()
      }
    }
  }
}

// MARK: - UISearchTextFieldDelegate
 
extension SearchViewController: UISearchTextFieldDelegate {
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    messageLabel.text = defaultMessageLabel
    results = []
    tableView.reloadData()
    return true
  }
}

// MARK: - UIGestureRecognizerDelegate

extension SearchViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if touch.view?.isDescendant(of: searchBar) == true {
      return false
    }
    
    return true
  }
}
