//
//  StringTracker.swift
//  Catalogr
//
//  Created by jfeigel on 4/17/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation
import os.log

class StringTracker {
  var frameIndex: Int64 = 0
  
  typealias StringObservation = (lastSeen: Int64, count: Int64)
  
  // Dictionary of seen strings. Used to get stable recognition before
  // displaying anything.
  var seenStrings = [String: StringObservation]()
  var bestCount = Int64(0)
  var bestString = ""
  
  func logFrame(strings: [String]) {
    for string in strings {
      if seenStrings[string] == nil {
        seenStrings[string] = (lastSeen: Int64(0), count: Int64(-1))
      }
      seenStrings[string]?.lastSeen = frameIndex
      seenStrings[string]?.count += 1
    }
    
    var obsoleteStrings = [String]()
    
    // Go through strings and prune any that have not been seen in while.
    // Also find the (non-pruned) string with the greatest count.
    for (string, obs) in seenStrings {
      // Remove previously seen text after 30 frames (~1s).
      if obs.lastSeen < frameIndex - 30 {
        obsoleteStrings.append(string)
      }
      
      // Find the string with the greatest count.
      let count = obs.count
      if !obsoleteStrings.contains(string) && count > bestCount {
        bestCount = Int64(count)
        bestString = string
      }
    }
    // Remove old strings.
    for string in obsoleteStrings {
      seenStrings.removeValue(forKey: string)
    }
    
    frameIndex += 1
  }
  
  func getStableString(_ countLimit: Int = 10) -> String? {
    // Require the recognizer to see the same string at least passed in limit times, or 10 by default.
    if bestCount >= countLimit {
      return bestString
    } else {
      return nil
    }
  }
  
  func reset(string: String) {
    seenStrings.removeValue(forKey: string)
    bestCount = 0
    bestString = ""
  }
}
