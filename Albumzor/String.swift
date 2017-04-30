//
//  String.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/19/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

extension String {
    func index(of substring: String) -> Index? {
        return range(of: substring)?.lowerBound
    }
    
    func cleanAlbumName() -> String {
        if let index = index(of: "(") {
            return substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else if let index = index(of: "[") {
            return substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            return self
        }
    }
    
    func cleanArtistName() -> String {
        if let index = index(of: "(") {
            return substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else if let index = index(of: ", composer") {
            return substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else if let index = index(of: "Feat") {
            return substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }  else {
            return self
        }
    }
    
    func truncated(maxLength: Int) -> String {
        let length = self.distance(from: self.startIndex, to: self.endIndex)
        return self.substring(to: self.index(self.startIndex, offsetBy: min(maxLength,length)))
    }
    
}

