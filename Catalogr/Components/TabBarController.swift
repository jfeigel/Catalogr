//
//  TabBarController.swift
//  Catalogr
//
//  Created by jfeigel on 4/10/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
  
  var centerTabBarItem: UIButton!

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
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    centerTabBarItem.layer.borderColor = UIColor.systemBackground.cgColor
  }
  
  @objc func centerTabBarItemAction(_ sender: UIButton) {
    self.selectedViewController = self.viewControllers![0]
    self.selectedIndex = 0
    ((self.viewControllers![0] as! UINavigationController).visibleViewController! as! BookshelfContainerViewController).handleScannerPresent(UIBarButtonItem())
  }
  
}

final class NoopViewController: UIViewController {}
