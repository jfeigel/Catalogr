//
//  ImageCacheType.swift
//  Catalogr
//
//  Created by jfeigel on 4/29/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

/// Declares in-memory image cache
protocol ImageCacheType: class {
  /// Returns the image associated with a given url
  func image(for url: URL) -> UIImage?
  
  /// Inserts the image of the specified url in the cache
  func insertImage(_ image: UIImage?, for url: URL)
  
  /// Removes the image of the specified url in the cache
  func removeImage(for url: URL)
  
  /// Removes all images from the cache
  func removeAllImages()
  
  /// Accesses the value associated with the given key for reading and writing
  subscript(_ url: URL) -> UIImage? { get set }
}
