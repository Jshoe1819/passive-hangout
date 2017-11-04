//
//  Sequence+Shuffled.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 11/3/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
