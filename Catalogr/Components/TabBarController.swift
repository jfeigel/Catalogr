//
//  TabBarController.swift
//  Catalogr
//
//  Created by jfeigel on 4/10/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit
import AVFoundation
import os.log

import BarcodeScanner

class TabBarController: UITabBarController {
  static let barcodeScannerViewController = BarcodeScannerViewController()
  var feedbackGenerator: UINotificationFeedbackGenerator? = nil
  
  var centerTabBarItem: UIButton!
  
  @IBAction func unwindToViewController(segue: UIStoryboardSegue, sender: Any?) {
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    centerTabBarItem = UIButton(type: .custom)
    let tabBarWidth = tabBar.frame.size.width
    let tabBarHeight = tabBar.frame.size.height
    let diameter: CGFloat = tabBarHeight * 1.5
    let radius: CGFloat = diameter / 2
    
    let smallConfiguration = UIImage.SymbolConfiguration(scale: .large)
    
    centerTabBarItem.frame = CGRect(x: (tabBarWidth / 2) - radius, y: (tabBarHeight - diameter) * 0.75, width: diameter, height: diameter)
    centerTabBarItem.layer.cornerRadius = radius
    centerTabBarItem.clipsToBounds = true
    centerTabBarItem.setImage(UIImage(systemName: "barcode.viewfinder", withConfiguration: smallConfiguration), for: .normal)
    centerTabBarItem.layer.backgroundColor = UIColor(hex: "#90dff4")!.cgColor
    centerTabBarItem.tintColor = .white
    centerTabBarItem.layer.borderColor = UIColor.systemBackground.cgColor
    centerTabBarItem.layer.borderWidth = 4.0
    centerTabBarItem.addTarget(self, action: #selector(centerTabBarItemAction(_:)), for: .touchUpInside)
    
    tabBar.addSubview(centerTabBarItem)
    
    TabBarController.barcodeScannerViewController.codeDelegate = self
    TabBarController.barcodeScannerViewController.errorDelegate = self
    TabBarController.barcodeScannerViewController.dismissalDelegate = self
    TabBarController.barcodeScannerViewController.headerViewController.titleLabel.textColor = UIColor.label
    TabBarController.barcodeScannerViewController.headerViewController.closeButton.tintColor = UIColor.systemBlue
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    centerTabBarItem.layer.borderColor = UIColor.systemBackground.cgColor
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "addBook":
      if let destVC = segue.destination as? AddBookViewController {
        destVC.isModalInPresentation = true
        destVC.book = sender as? Book
        destVC.selectedIndex = selectedIndex
      }
    case "scanISBN": break
    default:
      os_log("Unknown Segue Identifier found", log: OSLog.default, type: .error)
    }
  }
  
  @objc func centerTabBarItemAction(_ sender: UIButton) {
    present(TabBarController.barcodeScannerViewController, animated: true, completion: nil)
  }
  
}

// MARK: - BarcodeScannerCodeDelegate

extension TabBarController: BarcodeScannerCodeDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
    feedbackGenerator = UINotificationFeedbackGenerator()
    feedbackGenerator?.prepare()
    feedbackGenerator?.notificationOccurred(.success)
    feedbackGenerator = nil
    if type == AVMetadataObject.ObjectType.upca.rawValue {
      controller.reset(animated: false)
      controller.dismiss(animated: true, completion: {
        self.performSegue(withIdentifier: "scanISBN", sender: nil)
      })
    } else {
      GAPI.getBooks(searchText: code, type: .isbn) { (books, message) in
        if books == nil {
          controller.resetWithError(message: message)
        } else {
          controller.reset(animated: false)
          controller.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "addBook", sender: books![0])
          })
        }
      }
    }
  }
}

// MARK: - BarcodeScannerErrorDelegate

extension TabBarController: BarcodeScannerErrorDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
    feedbackGenerator = UINotificationFeedbackGenerator()
    feedbackGenerator?.prepare()
    feedbackGenerator?.notificationOccurred(.error)
    feedbackGenerator = nil
    os_log("%s", type: .error, error as CVarArg)
  }
}

// MARK: - BarcodeScannerDismissalDelegate

extension TabBarController: BarcodeScannerDismissalDelegate {
  func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
    controller.reset(animated: false)
    controller.dismiss(animated: true, completion: nil)
  }
}

final class NoopViewController: UIViewController {}
