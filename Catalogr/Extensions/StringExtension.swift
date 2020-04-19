//
//  StringExtension.swift
//  Catalogr
//
//  Created by jfeigel on 4/17/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import Foundation
import os.log

extension String {
  // Extracts the first ISBN-10 or ISBN-13 number found in the string, returning
  // the range of the number and the number itself as a tuple.
  // Returns nil if no number is found.
  func extractISBN() -> (Range<String.Index>, String)? {
    // Do a first pass to find any substring that could be an ISBN-10
    // ISBN-13 number.
    // ISBN x-xxx-xxxxx-x
    // ISBN xxx-x-xxx-xxxxx-x
    // Note that this doesn't only look for digits since some digits look
    // very similar to letters. This is handled later.
    let pattern = #"""
        (?x)                    # Verbose regex, allows comments
        ISBN\s*                 # Look for String starting with ISBN, and optional succeeding whitespace
        (\w{3})?                # Potential prefix for ISBN-13
        -?                      # Seperator
        (\w{1})                 # Capture Registration Group Element
        -                       # Seperator
        (\w{3})                 # Capture Registrant Element
        -                       # Seperator
        (\w{5})                 # Capture Publication Element
        -                       # Seperator
        (\w{1})                 # Capture Check Digit
        """#
    
    guard let range = self.range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
      // No ISBN number found.
      return nil
    }
    
    // Potential number found. Strip out punctuation, whitespace and ISBN string.
    var isbn = ""
    let substring = String(self[range])
    let nsrange = NSRange(substring.startIndex..., in: substring)
    do {
      // Extract the characters from the substring.
      let regex = try NSRegularExpression(pattern: pattern, options: [])
      if let match = regex.firstMatch(in: substring, options: [], range: nsrange) {
        for rangeInd in 1 ..< match.numberOfRanges {
          if let range = Range(match.range(at: rangeInd), in: substring) {
            isbn += substring[range]
          }
        }
      }
    } catch {
      os_log("Error %s when creating pattern", type: .error, error as CVarArg)
    }
    
    // Must be exactly 10 digits.
    guard isbn.count == 10 || isbn.count == 13 else {
      return nil
    }
    
    // Substitute commonly misrecognized characters, for example: 'S' -> '5' or 'l' -> '1'
    var result = ""
    let allowedChars = "0123456789"
    for var char in isbn {
      char = char.getSimilarCharacterIfNotIn(allowedChars: allowedChars)
      guard allowedChars.contains(char) else {
        return nil
      }
      result.append(char)
    }
    return (range, result)
  }
}
