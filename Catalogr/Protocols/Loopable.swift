//
//  Loopable.swift
//  Catalogr
//
//  Created by jfeigel on 4/15/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation

protocol Loopable {
  func allProps(limit: Int) -> [String: Any]
  func keys() -> [String]
}

extension Loopable {
  func allProps(limit: Int = Int.max) -> [String: Any] {
    return getAllProps(obj: self, count: 0, limit: limit)
  }
  
  func keys() -> [String] {
    return getKeys(obj: self)
  }
  
  private func getAllProps(obj: Any, count: Int, limit: Int) -> [String: Any] {
    let mirror = Mirror(reflecting: obj)
    var result: [String: Any] = [:]
    
    for (prop, val) in mirror.children {
      guard let prop = prop else { continue }
      if limit == count {
        result[prop] = val
      } else {
        let subResult = getAllProps(obj: val, count: count + 1, limit: limit)
        result[prop] = subResult.count == 0 ? val : subResult
      }
    }
    
    return result
  }
  
  private func getKeys(obj: Any) -> [String] {
    let mirror = Mirror(reflecting: obj)
    var result: [String] = []
    
    for (prop, _) in mirror.children {
      guard let prop = prop else { continue }
      result.append(prop)
    }
    
    return result
  }
}
