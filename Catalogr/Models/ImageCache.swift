//
//  ImageCache.swift
//  Catalogr
//
//  Created by jfeigel on 4/29/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

final class ImageCache {
  /// First level cache, that contains encoded images
  private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
    let cache = NSCache<AnyObject, AnyObject>()
    cache.countLimit = config.countLimit
    return cache
  }()
  
  /// Second level cache, that contains decoded images
  private lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
    let cache = NSCache<AnyObject, AnyObject>()
    cache.totalCostLimit = config.memoryLimit
    return cache
  }()
  
  private let lock = NSLock()
  private let config: Config
  
  struct Config {
    let countLimit: Int
    let memoryLimit: Int
    
    static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
  }
  
  init(config: Config = Config.defaultConfig) {
    self.config = config
  }
}

// MARK: - ImageCacheType

extension ImageCache: ImageCacheType {
  func image(for url: URL) -> UIImage? {
    lock.lock(); defer { lock.unlock() }
    // The best case scenario -> there is a decoded image
    if let decodedImage = decodedImageCache.object(forKey: url as AnyObject) as? UIImage {
      return decodedImage
    }
    
    // Search for the image data
    if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
      let decodedImage = image.decodedImage()
      decodedImageCache.setObject(decodedImage as AnyObject, forKey: url as AnyObject, cost: decodedImage.diskSize)
      return decodedImage
    }
    
    // Cached image not found
    return nil
  }
  
  func insertImage(_ image: UIImage?, for url: URL) {
    guard let image = image else { return removeImage(for: url) }
    let decodedImage = image.decodedImage()
    
    lock.lock(); defer { lock.unlock() }
    imageCache.setObject(image as AnyObject, forKey: url as AnyObject, cost: 1)
    decodedImageCache.setObject(decodedImage as AnyObject, forKey: url as AnyObject, cost: decodedImage.diskSize)
  }
  
  func removeImage(for url: URL) {
    lock.lock(); defer { lock.unlock() }
    imageCache.removeObject(forKey: url as AnyObject)
    decodedImageCache.removeObject(forKey: url as AnyObject)
  }
  
  func removeAllImages() {
    lock.lock(); defer { lock.unlock() }
    imageCache.removeAllObjects()
    decodedImageCache.removeAllObjects()
  }
  
  subscript(_ key: URL) -> UIImage? {
    get {
      return image(for: key)
    }
    set {
      return insertImage(newValue, for: key)
    }
  }
}

fileprivate extension UIImage {
  func decodedImage() -> UIImage {
    guard let cgImage = cgImage else { return self }
    
    let size = CGSize(width: cgImage.width, height: cgImage.height)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
    
    context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
    
    guard let decodedImage = context?.makeImage() else { return self }
    
    return UIImage(cgImage: decodedImage)
  }
  
  var diskSize: Int {
    guard let cgImage = cgImage else { return 0 }
    return cgImage.bytesPerRow * cgImage.height
  }
}
