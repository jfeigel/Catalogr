//
//  ImageLoader.swift
//  Catalogr
//
//  Created by jfeigel on 4/29/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class ImageLoader {
  static let shared = ImageLoader()
  
  private let cache: ImageCacheType
  private lazy var backgroundQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 5
    return queue
  }()
  
  init(cache: ImageCacheType = ImageCache()) {
    self.cache = cache
  }
  
  func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
    if let image = cache[url] {
      return Just(image).eraseToAnyPublisher()
    }
    
    return URLSession.shared.dataTaskPublisher(for: url)
      .map { (data, response) -> UIImage? in return UIImage(data: data) }
      .catch { error in return Just(nil) }
      .handleEvents(receiveOutput: { [unowned self] image in
        guard let image = image else { return }
        self.cache[url] = image
      })
      .subscribe(on: backgroundQueue)
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
}
