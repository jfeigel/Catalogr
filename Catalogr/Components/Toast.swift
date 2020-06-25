//
//  Toast.swift
//  Catalogr
//
//  Created by jfeigel on 6/19/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

class Toast {
  
  static let shared = Toast()
  
  var toastHeight: CGFloat = 44.0
  var viewOrigin: CGFloat = 0.0
  var toastOrigin: CGFloat = -44.0
  
  var timer: Timer?
  
  let toastView: UIView = {
    let toastView = UIView()
    toastView.translatesAutoresizingMaskIntoConstraints = false
    toastView.layer.shadowColor = UIColor.black.cgColor
    toastView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
    toastView.layer.shadowOpacity = 0.3
    
    return toastView
  }()
  
  let closeButton: UIButton = {
    let closeButton = UIButton()
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
    
    return closeButton
  }()
  
  let label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.adjustsFontSizeToFitWidth = true
    label.numberOfLines = 0
    
    return label
  }()
  
  init() {}
  
  func show(_ message: String, inView view: UIView?, canDismiss: Bool = true, backgroundColor: UIColor = UIColor(named: "tertiaryBackground")!, textColor: UIColor = .label) {
    
    guard let view = (view ?? SceneDelegate.shared?.window) else { return }
    
    toastView.backgroundColor = backgroundColor
    toastView.frame.origin.y = toastOrigin
        
    label.text = message
    label.textColor = textColor
    
    toastView.addSubview(label)
    toastView.addSubview(closeButton)
    
    view.addSubview(toastView)
    
    toastView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
    toastView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
    toastView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
    toastView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0).isActive = true
    
    label.centerYAnchor.constraint(equalTo: toastView.centerYAnchor, constant: 0.0).isActive = true
    label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10.0).isActive = true
    label.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -10.0).isActive = true
    label.heightAnchor.constraint(lessThanOrEqualToConstant: 34.0).isActive = true
    
    closeButton.centerYAnchor.constraint(equalTo: toastView.centerYAnchor, constant: 0.0).isActive = true
    closeButton.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10.0).isActive = true
    closeButton.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
    
    closeButton.addTarget(self, action: #selector(dismissToast(_:)), for: .touchUpInside)
    
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
      self.toastView.frame.origin.y = self.viewOrigin
    }, completion: nil)
    
    timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { timer in
      UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
        self.toastView.frame.origin.y = self.toastOrigin
      }, completion: { _ in
        self.toastView.removeFromSuperview()
      })
    })
  }
  
  @objc private func dismissToast(_ sender: UIButton) {
    timer?.fire()
  }
}
