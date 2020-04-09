//
//  RemoteImageExtension.swift
//  Catalogr
//
//  Created by jfeigel on 3/31/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

extension UIImageView {
  func load(url: URL, completion: @escaping (UIImage) -> ()) {
    DispatchQueue.global().async { [weak self] in
      if let data = try? Data(contentsOf: url) {
        if let image = UIImage(data: data) {
          DispatchQueue.main.async {
            self?.image = image
            completion(image)
          }
        }
      }
    }
  }
}
