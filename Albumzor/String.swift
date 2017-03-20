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
        } else {
            return self
        }
    }
}
